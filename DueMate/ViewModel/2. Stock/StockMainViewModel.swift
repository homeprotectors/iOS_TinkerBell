//
//  StockMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import Foundation
import Alamofire
import SwiftUI

class StockMainViewModel: ObservableObject {
    @Published var shouldRefresh: Bool = false
    @Published var showToast: Bool  = false
    @Published var error: NetworkError?
    @Published var items: [StockItem] = []
    @Published var sections: [StockSection: [StockItem]] = [:]
    
    private let network = DefaultNetworkService.shared
    
    func fetchStocks() {
        print("STOCK LIST FETCH START")
        Task {
            do {
                let items: [StockItem] = try await network.request(StockRouter.getItems)
                await MainActor.run {
                    self.items = items
                    self.groupBySection()
                }
                print("🎉 Stock fetch 성공!")
            } catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 Stock fetch 실패!  \(error.localizedDescription)")
            }
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
    
    func updateQuantity(for id:Int, newQuantity: Int) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].currentQuantity = newQuantity
            groupBySection()
        }
        
        Task {
            do {
                let body = UpdateStockRequest(name: nil, unitQuantity: nil, unitDays: nil, updatedQuantity: newQuantity)
                let item: StockItemTemp = try await network.request(StockRouter.update(id: id,body: body))
                await MainActor.run {
                    if let index = self.items.firstIndex(where: {$0.id == item.id}) {
                        self.items[index].currentQuantity = item.updatedQuantity
                        self.groupBySection()
                    }
                }
                print("🎉 \(id) : \(newQuantity) update 성공")
            }
            catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 update 실패! \(error.localizedDescription)")
            }
        }
    }
    
    func updateInfo(id: Int, item: StockItem ) {
        // UI update
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index] = item
            groupBySection()
        }
        
        Task {
            do {
                let body = UpdateStockRequest(name: item.name, unitQuantity: item.unitQuantity, unitDays: item.unitDays, updatedQuantity: nil)
                let item: StockItem = try await network.request(StockRouter.update(id: id,body: body))
                await MainActor.run {
                    if let index = self.items.firstIndex(where: {$0.id == item.id}) {
                        self.items[index] = item
                        self.groupBySection()
                    }
                }
                print("🎉 update 성공!")
            }
            catch {
                await MainActor.run {
                    self.fetchStocks()
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 update 실패! \(error.localizedDescription)")
            }
        }
    }
    
    func createStock(item: StockItem) {
        //UI update
        items.append(item)
        groupBySection()
        
        //Server
        Task {
            do {
                let body = CreateStockRequest(
                    name: item.name,
                    updatedQuantity: item.currentQuantity,
                    unitDays: item.unitDays,
                    unitQuantity: item.unitQuantity
                )
                let createdItem: StockItem = try await DefaultNetworkService.shared.request(StockRouter.create(body: body))
                await MainActor.run {
                    if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                        
                        self.groupBySection()
                    }
                    print("🎉 Stock 생성 완료! \(createdItem.id)")
                }
            }
            catch {
                print("🚨 Stock 생성 실패: \(error)")
                self.items.removeAll { $0.id == item.id }
                self.groupBySection()
                if let nwError = error as? NetworkError {
                    await ErrorHandler.shared.handle(nwError)
                } else {
                    print("💥 Stock ErrorHandling Failed:  \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteStock(id: Int) {
        
        // UI update
        let itemToRemove = items.first { $0.id == id }
        items.removeAll { $0.id == id }
        groupBySection()
        
        Task {
            do {
                try await network.requestWithoutResponse(StockRouter.delete(id: id))
                await MainActor.run {
                    // 로컬에서 즉시 제거
                    self.items.removeAll { $0.id == id }
                    self.groupBySection()
                }
                print("🎉 \(id) 삭제 성공")
            } catch {
                await MainActor.run {
                    if let item = itemToRemove {
                        self.items.append(item)
                        self.groupBySection()
                    }
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 삭제 실패! \(error.localizedDescription)")
            }
        }
    }
    
}

