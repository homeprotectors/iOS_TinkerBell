//
//  ChoreDetailViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/15/25.
//

import SwiftUI
import Alamofire

class ChoreDetailViewModel: ObservableObject {
    @Published var historyDates: [ChoreHistory] = []
    @Published var title: String = ""
    @Published var cycleDays: String = ""
    @Published var reminderOption: ReminderOptions = .none
    @Published var shoudRedirectMain: Bool = false
    @Published var isHistoryUpdated: Bool = false
    
    @Published var firstTitle: String = ""
    @Published var firstCycleDays: String = ""
    @Published var firstReminderOption: ReminderOptions = .none
    
    private let network = DefaultNetworkService.shared
    
    func firstInputSetting(title: String, cycleDays: String, reminderOption: ReminderOptions) {
        self.title = title
        self.cycleDays = cycleDays
        self.reminderOption = reminderOption
        
        firstTitle = title
        firstCycleDays = cycleDays
        firstReminderOption = reminderOption
    }
    
    func hasInputChanges() -> Bool {
        return title != firstTitle || cycleDays != firstCycleDays || reminderOption != firstReminderOption
    }
    
    func isInHistory(_ date: Date) -> Bool {
        historyDates.contains(where: {$0.doneDate == date.toString()})
    }
    func fetchHistory(for id: Int)  {
        print("fetchHistory")
        Task {
            do {
                let historyResult: GetChoreHistoryResponse = try await network.request(ChoreRouter.getHistory(id: id))
                await MainActor.run {
                    self.historyDates = historyResult.history
                }
                print("🎉 History fetch 성공!")
            } catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 History fetch 실패! \(error.localizedDescription)")
            }
        }
    }
    
    func editHistory(complete: Bool, id: Int, date: String) {
        let body = EditChoreHistoryRequest(choreId: id, doneDate: date)
        Task {
            do {
                if complete {
                    try await network.requestWithoutResponse(ChoreRouter.complete(body: body))
                } else {
                    try await network.requestWithoutResponse(ChoreRouter.undo(body: body))
                }
                
                await MainActor.run {
                    isHistoryUpdated = true
                }
                print("🎉 complete \(complete) 성공! \(date)")
            }
            catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 complete 실패! \(error.localizedDescription)")
            }
        }
        fetchHistory(for:id)
    }
    
    
    
    func updateChore(for id:Int) {
        let intCycledays = Int(cycleDays) ?? 1
        let reminderDays = reminderOption.getDays()
        let body = UpdateChoreRequest(title: title, cycleDays: intCycledays, reminderDays: reminderDays)
        
        Task {
            do {
                try await network.requestWithoutResponse(ChoreRouter.update(id: id,body: body))
                await MainActor.run {
                    shoudRedirectMain = true
                }
                print("🎉 update 성공! \(title)")
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
    
    func deleteChore(id:Int) {
        print("deleteChore ::: \(id)")
        Task {
            do {
                try await network.requestWithoutResponse(ChoreRouter.delete(id: id))
                await MainActor.run {
                    shoudRedirectMain = true
                }
                print("🎉 delete 성공! \(title)")
            }
            catch {
                await MainActor.run {
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
