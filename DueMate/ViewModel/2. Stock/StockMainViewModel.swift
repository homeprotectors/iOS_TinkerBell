//
//  StockMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class StockMainViewModel: ObservableObject, ErrorReporting {
    @Published var shouldRefresh: Bool = false
    @Published var items: [StockItem] = []
    @Published var sections: [StockSection: [StockItem]] = [:]
    
    private let network = DefaultNetworkService.shared
    
    func fetchStocks() async {
        do {
            items = try await network.request(StockRouter.getItems)
            groupBySection()
        } catch {
            await reportError(error)
        }
    }
    
    
    func groupBySection() {
        let grouped = Dictionary(grouping: items) { item in
            StockSection.section(for: item.remainingDays)
        }
        
        self.sections = grouped.mapValues { section in
            section.sorted { lhs, rhs in
                if lhs.remainingDays != rhs.remainingDays {
                    return lhs.remainingDays < rhs.remainingDays
                }
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
        }
        
    }

    private func applyAnimated(_ updates: () -> Void) {
        withAnimation {
            updates()
        }
    }
    
    func updateQuantity(for id:Int, newQuantity: Int) {
        let previousItems = items
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].currentQuantity = newQuantity
            items[index].remainingDays = (newQuantity * items[index].unitDays) / items[index].unitQuantity
            groupBySection()
        }
        
        Task {
            do {
                let body = UpdateStockRequest(name: nil, unitQuantity: nil, unitDays: nil, updatedQuantity: newQuantity)
                let item: StockItem = try await network.request(StockRouter.update(id: id,body: body))
                await MainActor.run {
                    if let index = self.items.firstIndex(where: {$0.id == item.id}) {
                        self.items[index].currentQuantity = item.currentQuantity
                        self.groupBySection()
                    }
                }
            }
            catch {
                await MainActor.run {
                    self.items = previousItems
                    self.groupBySection()
                }
                await reportError(error)
            }
        }
    }
    
    func updateInfo(id: Int, item: StockItem ) async -> Bool {
        // Optimistic UI update (snapshot for rollback)
        let previousItems = items
        if let index = items.firstIndex(where: { $0.id == id }) {
            applyAnimated {
                items[index] = item
                groupBySection()
            }
        }
        
        do {
            let body = UpdateStockRequest(name: item.name, unitQuantity: item.unitQuantity, unitDays: item.unitDays, updatedQuantity: nil)
            let item: StockItem = try await network.request(StockRouter.update(id: id,body: body))
            if let index = self.items.firstIndex(where: {$0.id == item.id}) {
                applyAnimated {
                    self.items[index] = item
                    self.groupBySection()
                }
            }
            return true
        }
        catch {
            applyAnimated {
                self.items = previousItems
                self.groupBySection()
            }
            await reportError(error)
            return false
        }
    }
    
    func createStock(item: StockItem) async -> Bool {
        //UI update
        applyAnimated {
            items.append(item)
            groupBySection()
        }
        
        //Server
        do {
            let body = CreateStockRequest(
                name: item.name,
                updatedQuantity: item.currentQuantity,
                unitDays: item.unitDays,
                unitQuantity: item.unitQuantity
            )
            let createdItem: StockItem = try await DefaultNetworkService.shared.request(StockRouter.create(body: body))
            applyAnimated {
                if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                    // Replace optimistic temporary item with server-confirmed item (real id).
                    self.items[index] = createdItem
                } else {
                    // Fallback in case local optimistic item was removed before response arrived.
                    self.items.append(createdItem)
                }
                self.groupBySection()
            }
            return true
        }
        catch {
            applyAnimated {
                self.items.removeAll { $0.id == item.id }
                self.groupBySection()
            }
            await reportError(error)
            return false
        }
    }
    
    func deleteStock(id: Int) {
        
        // Optimistic UI update (snapshot for rollback)
        let previousItems = items
        items.removeAll { $0.id == id }
        groupBySection()
        
        Task {
            do {
                try await network.requestWithoutResponse(StockRouter.delete(id: id))
            } catch {
                await MainActor.run {
                    self.items = previousItems
                    self.groupBySection()
                }
                await reportError(error)
            }
        }
    }
    
}
