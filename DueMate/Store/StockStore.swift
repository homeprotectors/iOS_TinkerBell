//
//  StockStore.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Combine
import Foundation

@MainActor
final class StockStore: ObservableObject, ErrorReporting {
    static let shared = StockStore()
    
    @Published private(set) var items: [StockItem] = []
    @Published private(set) var sections: [StockSection: [StockItem]] = [:]
    @Published private(set) var isLoading = false
    
    private let repository: StockRepository
    private let cacheTTL: TimeInterval
    
    private var lastLoadedAt: Date?
    private var loadTask: Task<Void, Never>?
    private var isInvalidated = true
    
    private init(
        repository: StockRepository = .shared,
        cacheTTL: TimeInterval = 120
    ) {
        self.repository = repository
        self.cacheTTL = cacheTTL
    }
    
    func loadIfNeeded(force: Bool = false, shouldPresentErrors: Bool = true) async {
        if let loadTask {
            await loadTask.value
            return
        }
        
        guard force || shouldReload else { return }
        
        isLoading = true
        let repository = self.repository
        
        let task = Task { [shouldPresentErrors] in
            do {
                let remoteItems = try await repository.fetchItems()
                await MainActor.run {
                    self.applySnapshot(remoteItems)
                }
            } catch {
                if shouldPresentErrors {
                    await self.reportError(error)
                }
            }
            
            await MainActor.run {
                self.isLoading = false
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
    
    func create(from draft: StockDraft) async -> Bool {
        let placeholder = makeTemporaryItem(from: draft)
        items.append(placeholder)
        regroupSections()
        markFresh()
        
        do {
            let createdItem = try await repository.createStock(from: draft)
            
            if let index = items.firstIndex(where: { $0.id == placeholder.id }) {
                items[index] = createdItem
            } else {
                items.append(createdItem)
            }
            
            regroupSections()
            HomeStore.shared.invalidate()
            markFresh()
            return true
        } catch {
            items.removeAll { $0.id == placeholder.id }
            regroupSections()
            await reportError(error)
            return false
        }
    }
    
    func updateInfo(id: Int, draft: StockDraft, currentQuantity: Int) async -> Bool {
        let previousItems = items
        let optimisticItem = StockItem(
            id: id,
            name: draft.name,
            unitDays: draft.unitDays,
            unitQuantity: draft.unitQuantity,
            currentQuantity: currentQuantity,
            remainingDays: draft.unitQuantity > 0 ? (currentQuantity * draft.unitDays) / draft.unitQuantity : 0
        )
        
        replaceItem(optimisticItem)
        markFresh()
        
        do {
            let updatedItem = try await repository.updateStock(
                id: id,
                name: draft.name,
                unitQuantity: draft.unitQuantity,
                unitDays: draft.unitDays,
                updatedQuantity: nil
            )
            replaceItem(updatedItem)
            HomeStore.shared.invalidate()
            markFresh()
            return true
        } catch {
            items = previousItems
            regroupSections()
            await reportError(error)
            return false
        }
    }
    
    func updateQuantity(for id: Int, newQuantity: Int) async {
        let previousItems = items
        
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].currentQuantity = newQuantity
            items[index].remainingDays = items[index].unitQuantity > 0
            ? (newQuantity * items[index].unitDays) / items[index].unitQuantity
            : 0
            regroupSections()
            markFresh()
        }
        
        do {
            let updatedItem = try await repository.updateStock(
                id: id,
                name: nil,
                unitQuantity: nil,
                unitDays: nil,
                updatedQuantity: newQuantity
            )
            replaceItem(updatedItem)
            HomeStore.shared.invalidate()
            markFresh()
        } catch {
            items = previousItems
            regroupSections()
            await reportError(error)
        }
    }
    
    func delete(id: Int) async {
        let previousItems = items
        items.removeAll { $0.id == id }
        regroupSections()
        markFresh()
        
        do {
            try await repository.deleteStock(id: id)
            HomeStore.shared.invalidate()
        } catch {
            items = previousItems
            regroupSections()
            await reportError(error)
        }
    }
    
    private var shouldReload: Bool {
        guard !isInvalidated else { return true }
        guard let lastLoadedAt else { return true }
        return Date().timeIntervalSince(lastLoadedAt) >= cacheTTL
    }
    
    private func applySnapshot(_ remoteItems: [StockItem]) {
        items = sortItems(remoteItems)
        regroupSections()
        markFresh()
    }
    
    private func replaceItem(_ item: StockItem) {
        items.removeAll { $0.id == item.id }
        items.append(item)
        items = sortItems(items)
        regroupSections()
    }
    
    private func regroupSections() {
        sections = Dictionary(grouping: items) { item in
            StockSection.section(for: item.remainingDays)
        }
        .mapValues(sortItems)
    }
    
    private func sortItems(_ items: [StockItem]) -> [StockItem] {
        items.sorted { lhs, rhs in
            if lhs.remainingDays != rhs.remainingDays {
                return lhs.remainingDays < rhs.remainingDays
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
    
    private func makeTemporaryItem(from draft: StockDraft) -> StockItem {
        StockItem(
            id: -Int.random(in: 1000...9999),
            name: draft.name,
            unitDays: draft.unitDays,
            unitQuantity: draft.unitQuantity,
            currentQuantity: draft.currentQuantity,
            remainingDays: draft.remainingDays
        )
    }
    
    private func markFresh() {
        lastLoadedAt = Date()
        isInvalidated = false
    }
}
