//
//  ChoreMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import Foundation
import SwiftUI
import Alamofire


class ChoreMainViewModel: ObservableObject {
    @Published var shouldRefresh: Bool = false
    @Published var showToast: Bool  = false
    @Published var error: NetworkError?
    @Published var items: [ChoreItem] = []
    @Published var selectedCategory: String? = nil
    @Published var itemToUpdate: ChoreItem? = nil
    
    private let network = DefaultNetworkService.shared
    
    var filteredItems: [ChoreItem] {
            if let selected = selectedCategory {
                return items.filter { $0.roomCategory == selected }
            } else {
                return items
            }
        }
    
    func fetchChores() {
        Task {
            do {
                let itemsResponse: [ChoreItemResponse] = try await network.request(ChoreRouter.getItems)
                let items = itemsResponse.map { ChoreItem(from: $0) }
                await MainActor.run {
                    self.items = items
                    self.sortByDueDate()
                }
                print("🎉 Chore fetch 성공!")
            } catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 Chore fetch 실패!  \(error.localizedDescription)")
            }
        }
    }
    
    func completeChore(_ chore: ChoreItem) {
        Task {
            do {
                let body = EditChoreHistoryRequest(
                    choreId: chore.id,
                    doneDate: DateFormatter.yyyyMMdd.string(from: Date())
                )
                try await network.requestWithoutResponse(ChoreRouter.complete(body: body))
                await MainActor.run {
                    fetchChores()
                }
                print("🎉 Complete 성공!")
            } catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 Complete 실패! \(error.localizedDescription)")
            }
        }
    }
    
    func sortByDueDate() {
        items.sort { $0.nextDue < $1.nextDue }
    }
    
    func deleteChore(id: Int) {
        //UI update
        let itemToRemove = items.first { $0.id == id }
        items.removeAll { $0.id == id }
        
        Task {
            do {
                try await network.requestWithoutResponse(ChoreRouter.delete(id: id))
                await MainActor.run {
                    self.items.removeAll{ $0.id == id }
                }
                print("🎉 \(id) 삭제 성공")
            }
            catch {
                await MainActor.run {
                    if let item = itemToRemove {
                        self.items.append(item)
                        
                    }
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 delete 실패! \(error.localizedDescription)\nid: \(id)")
            }
        }
        
    }
}

