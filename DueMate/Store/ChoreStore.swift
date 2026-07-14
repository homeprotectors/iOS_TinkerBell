//
//  ChoreStore.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Combine
import Foundation

@MainActor
final class ChoreStore: ObservableObject, ErrorReporting {
    static let shared = ChoreStore()
    
    @Published private(set) var items: [ChoreItem] = []
    @Published private(set) var isLoading = false
    
    private let repository: ChoreRepository
    private let cacheTTL: TimeInterval
    
    private var lastLoadedAt: Date?
    private var loadTask: Task<Void, Never>?
    private var isInvalidated = true
    private var mutationRevision = 0
    
    private init(
        repository: ChoreRepository = .shared,
        cacheTTL: TimeInterval = 120
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
                let remoteItems = try await repository.fetchItems()
                await MainActor.run {
                    guard expectedMutationRevision == nil ||
                            expectedMutationRevision == self.mutationRevision else {
                        return
                    }
                    self.applySnapshot(remoteItems)
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
    
    func create(from draft: ChoreDraft) async -> Bool {
        do {
            let createdItem = try await repository.createChore(from: draft)
            
            if let createdItem {
                upsert(createdItem)
                HomeStore.shared.upsertChore(createdItem)
                reconcileAfterLocalMutation()
                HomeStore.shared.reconcileAfterLocalMutation()
                return true
            }
            
            invalidate()
            HomeStore.shared.invalidate()
            await loadIfNeeded(force: true, shouldPresentErrors: false)
            return true
        } catch {
            await reportError(error)
            return false
        }
    }
    
    func update(id: Int, draft: ChoreDraft) async -> Bool {
        do {
            let updatedItem = try await repository.updateChore(id: id, draft: draft)
            upsert(updatedItem)
            HomeStore.shared.upsertChore(updatedItem)
            markFresh()
            return true
        } catch {
            await reportError(error)
            return false
        }
    }
    
    func delete(id: Int) async {
        let previousItems = items
        let previousHomeSections = HomeStore.shared.sections
        
        mutationRevision += 1
        items.removeAll { $0.id == id }
        HomeStore.shared.removeChore(id: id)
        markFresh()
        
        do {
            try await repository.deleteChore(id: id)
        } catch {
            mutationRevision += 1
            items = previousItems
            HomeStore.shared.restore(previousHomeSections)
            await reportError(error)
        }
    }
    
    func applyCompletion(from item: HomeItem, completedOn: Date) {
        guard let recurrenceRule = item.recurrenceRule,
              let recurrenceType = item.recurrenceType,
              let roomCategory = item.roomCategory else {
            return
        }
        
        let nextDue = RecurrenceNextDueCalculator.nextDueString(
            for: recurrenceRule,
            from: completedOn
        )
        
        let updatedItem = ChoreItem(
            id: item.id,
            title: item.title,
            recurrenceType: recurrenceType,
            selectedCycle: item.selectedCycle,
            roomCategory: roomCategory.lowercased(),
            nextDue: nextDue
        )
        
        upsert(updatedItem)
        reconcileAfterLocalMutation()
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
    
    private func applySnapshot(_ remoteItems: [ChoreItem]) {
        items = remoteItems.sorted { $0.nextDue < $1.nextDue }
        markFresh()
    }
    
    private func upsert(_ item: ChoreItem) {
        mutationRevision += 1
        items.removeAll { $0.id == item.id }
        items.append(item)
        items.sort { $0.nextDue < $1.nextDue }
    }
    
    private func markFresh() {
        lastLoadedAt = Date()
        isInvalidated = false
    }
}
