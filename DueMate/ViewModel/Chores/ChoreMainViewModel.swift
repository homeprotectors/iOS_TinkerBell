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
    
    private let network = DefaultNetworkService.shared
    
    func fetchChores() {
        print("♻️ Chore List Fetching")
        Task {
            do {
                let items: [ChoreItem] = try await network.request(ChoreRouter.getItems)
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
}

