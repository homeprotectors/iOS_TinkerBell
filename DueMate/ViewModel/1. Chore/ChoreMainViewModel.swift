//
//  ChoreMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import Foundation
import SwiftUI


@MainActor
class ChoreMainViewModel: ObservableObject, ErrorReporting {
    @Published var shouldRefresh: Bool = false
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
    
    func fetchChores() async {
        do {
            let itemsResponse: [ChoreItemResponse] = try await network.request(ChoreRouter.getItems)
            items = itemsResponse.map { ChoreItem(from: $0) }
            sortByDueDate()
        } catch {
            await reportError(error)
        }
    }
    
    
    func sortByDueDate() {
        items.sort { $0.nextDue < $1.nextDue }
    }
    
    func deleteChore(id: Int) {
        // Optimistic UI update (snapshot for rollback)
        let previousItems = items
        items.removeAll { $0.id == id }
        
        Task {
            do {
                try await network.requestWithoutResponse(ChoreRouter.delete(id: id))
            }
            catch {
                await MainActor.run {
                    self.items = previousItems
                    self.sortByDueDate()
                }
                await reportError(error)
            }
        }
        
    }
}
