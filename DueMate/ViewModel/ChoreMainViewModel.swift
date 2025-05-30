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
    @Published var items: [ChoreItem] = []
    
    private let network = DefaultNetworkService.shared
    
    func fetchChores() {
        print("Main list fetch start!")
        Task {
            do {
                let items: [ChoreItem] = try await network.request(ChoreRouter.getItems)
                await MainActor.run {
                    self.items = items
                    self.sortByDueDate()
                }
                print("🎉 Chore fetch 성공!")
            } catch {
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
                fetchChores()
            } catch {
                print("❌ Complete failed: \(error.localizedDescription)")
            }
        }
    }
    
    func sortByDueDate() {
        items.sort { $0.nextDue < $1.nextDue }
    }
    
    func getListColor(due: String) -> Color {
        guard let remainDays = due.daysFromToday() else {
            return ListColor.normal
        }
        switch remainDays {
        case ...0:
            return ListColor.overdue
        case 1...3:
            return ListColor.warning
        default:
            return ListColor.normal
        }
    }
    
}

