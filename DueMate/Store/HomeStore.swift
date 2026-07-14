//
//  HomeStore.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Combine
import Foundation

@MainActor
final class HomeStore: ObservableObject, ErrorReporting {
    static let shared = HomeStore()
    
    @Published private(set) var sections: [HomeSection] = []
    @Published private(set) var isLoading = false
    
    private let repository: HomeRepository
    private let cacheTTL: TimeInterval
    
    private var lastLoadedAt: Date?
    private var loadTask: Task<Void, Never>?
    private var isInvalidated = true
    private var mutationRevision = 0
    
    private init(
        repository: HomeRepository = .shared,
        cacheTTL: TimeInterval = 60
    ) {
        self.repository = repository
        self.cacheTTL = cacheTTL
    }
    
    func loadIfNeeded(
        force: Bool = false,
        shouldPresentErrors: Bool = true,
        updatesLoadingState: Bool = true,
        expectedMutationRevision: Int? = nil
    ) async {
        while let loadTask {
            await loadTask.value
        }
        
        guard force || shouldReload else { return }
        
        if updatesLoadingState {
            isLoading = true
        }
        let repository = self.repository
        
        let task = Task { [shouldPresentErrors, updatesLoadingState, expectedMutationRevision] in
            do {
                let remoteSections = try await repository.fetchHomeSections()
                await MainActor.run {
                    guard expectedMutationRevision == nil ||
                            expectedMutationRevision == self.mutationRevision else {
                        return
                    }
                    self.sections = remoteSections
                    self.markFresh()
                }
            } catch {
                if shouldPresentErrors {
                    await self.reportError(error)
                }
            }
            
            await MainActor.run {
                if updatesLoadingState {
                    self.isLoading = false
                }
                self.loadTask = nil
            }
        }
        
        loadTask = task
        await task.value
    }
    
    func refresh() async {
        await loadIfNeeded(force: true)
    }
    
    func invalidate() {
        isInvalidated = true
    }
    
    func restore(_ snapshot: [HomeSection]) {
        mutationRevision += 1
        sections = snapshot
    }
    
    func complete(_ item: HomeItem) async {
        guard !item.shoppingContainer else { return }
        
        let snapshot = sections
        let completedOn = Date()
        
        if let updatedItem = updatedHomeItem(afterCompleting: item, completedOn: completedOn) {
            upsertChore(updatedItem)
        } else {
            removeChore(id: item.id)
        }
        
        do {
            try await repository.completeChore(id: item.id, doneDate: completedOn.toString())
            ChoreStore.shared.applyCompletion(from: item, completedOn: completedOn)
            reconcileAfterLocalMutation()
        } catch {
            restore(snapshot)
            await reportError(error)
        }
    }
    
    func upsertChore(_ chore: ChoreItem) {
        let homeItem = HomeItem(
            id: chore.id,
            title: chore.title,
            recurrenceType: chore.recurrenceType,
            selectedCycle: chore.selectedCycle,
            roomCategory: chore.roomCategory,
            nextDue: chore.nextDue,
            shoppingContainer: false,
            shoppingItems: nil
        )
        
        upsertChore(homeItem)
        markFresh()
    }
    
    func removeChore(id: Int) {
        mutationRevision += 1
        var buckets = bucketedSections(from: sections)
        for bucket in HomeBucket.allCases {
            buckets[bucket]?.removeAll { !$0.shoppingContainer && $0.id == id }
        }
        rebuildSections(from: buckets)
        markFresh()
    }
    
    func reconcileAfterLocalMutation() {
        let expectedMutationRevision = mutationRevision
        invalidate()
        
        Task { @MainActor [expectedMutationRevision] in
            await loadIfNeeded(
                force: true,
                shouldPresentErrors: false,
                updatesLoadingState: false,
                expectedMutationRevision: expectedMutationRevision
            )
        }
    }
    
    private var shouldReload: Bool {
        guard !isInvalidated else { return true }
        guard let lastLoadedAt else { return true }
        return Date().timeIntervalSince(lastLoadedAt) >= cacheTTL
    }
    
    private func markFresh() {
        lastLoadedAt = Date()
        isInvalidated = false
    }
    
    private func updatedHomeItem(afterCompleting item: HomeItem, completedOn: Date) -> HomeItem? {
        guard let recurrenceRule = item.recurrenceRule else { return nil }
        
        let nextDue = RecurrenceNextDueCalculator.nextDueString(
            for: recurrenceRule,
            from: completedOn
        )
        
        let updatedItem = HomeItem(
            id: item.id,
            title: item.title,
            recurrenceType: item.recurrenceType,
            selectedCycle: item.selectedCycle,
            roomCategory: item.roomCategory,
            nextDue: nextDue,
            shoppingContainer: false,
            shoppingItems: nil
        )
        
        return bucket(for: updatedItem) == nil ? nil : updatedItem
    }
    
    private func upsertChore(_ item: HomeItem) {
        guard !item.shoppingContainer,
              let targetBucket = bucket(for: item) else {
            removeChore(id: item.id)
            return
        }
        
        mutationRevision += 1
        var buckets = bucketedSections(from: sections)
        for bucket in HomeBucket.allCases {
            buckets[bucket]?.removeAll { !$0.shoppingContainer && $0.id == item.id }
        }
        
        buckets[targetBucket, default: []].append(item)
        rebuildSections(from: buckets)
    }
    
    private func rebuildSections(from buckets: [HomeBucket: [HomeItem]]) {
        sections = HomeBucket.allCases.compactMap { bucket in
            let items = sortedHomeItems(buckets[bucket] ?? [])
            guard !items.isEmpty else { return nil }
            return HomeSection(title: bucket.title, list: items)
        }
    }
    
    private func bucketedSections(from sections: [HomeSection]) -> [HomeBucket: [HomeItem]] {
        var buckets = Dictionary(uniqueKeysWithValues: HomeBucket.allCases.map { ($0, [HomeItem]()) })
        
        for section in sections {
            guard let bucket = HomeBucket(title: section.title) else { continue }
            buckets[bucket] = section.list
        }
        
        return buckets
    }
    
    private func sortedHomeItems(_ items: [HomeItem]) -> [HomeItem] {
        items.sorted { lhs, rhs in
            switch (lhs.shoppingContainer, rhs.shoppingContainer) {
            case (true, false):
                return true
            case (false, true):
                return false
            default:
                let lhsDue = lhs.nextDue ?? "9999-12-31"
                let rhsDue = rhs.nextDue ?? "9999-12-31"
                if lhsDue != rhsDue {
                    return lhsDue < rhsDue
                }
                return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            }
        }
    }
    
    private func bucket(for item: HomeItem) -> HomeBucket? {
        guard let nextDue = item.nextDue,
              let dueDate = DateFormatter.yyyyMMdd.date(from: nextDue) else {
            return nil
        }
        
        return bucket(for: dueDate)
    }
    
    private func bucket(for date: Date, today: Date = Date(), calendar: Calendar = .current) -> HomeBucket? {
        let referenceDate = calendar.startOfDay(for: today)
        let targetDate = calendar.startOfDay(for: date)
        let nextWeekReference = calendar.date(byAdding: .weekOfYear, value: 1, to: referenceDate)
        let nextMonthReference = calendar.date(byAdding: .month, value: 1, to: referenceDate)
        
        if isSameWeek(targetDate, as: referenceDate, calendar: calendar) {
            return .thisWeek
        }
        
        if let nextWeekReference,
           isSameWeek(targetDate, as: nextWeekReference, calendar: calendar) {
            return .nextWeek
        }
        
        if calendar.isDate(targetDate, equalTo: referenceDate, toGranularity: .month) {
            return .thisMonth
        }
        
        if let nextMonthReference,
           calendar.isDate(targetDate, equalTo: nextMonthReference, toGranularity: .month) {
            return .nextMonth
        }
        
        return nil
    }
    
    private func isSameWeek(_ lhs: Date, as rhs: Date, calendar: Calendar) -> Bool {
        let lhsComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lhs)
        let rhsComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: rhs)
        return lhsComponents.yearForWeekOfYear == rhsComponents.yearForWeekOfYear &&
        lhsComponents.weekOfYear == rhsComponents.weekOfYear
    }
}

private enum HomeBucket: CaseIterable {
    case thisWeek
    case nextWeek
    case thisMonth
    case nextMonth
    
    var title: String {
        switch self {
        case .thisWeek: return "이번주 할 일"
        case .nextWeek: return "다음주 할 일"
        case .thisMonth: return "이번달 할 일"
        case .nextMonth: return "다음달 할 일"
        }
    }
    
    init?(title: String) {
        switch title {
        case "이번주 할 일":
            self = .thisWeek
        case "다음주 할 일":
            self = .nextWeek
        case "이번달 할 일":
            self = .thisMonth
        case "다음달 할 일":
            self = .nextMonth
        default:
            return nil
        }
    }
}
