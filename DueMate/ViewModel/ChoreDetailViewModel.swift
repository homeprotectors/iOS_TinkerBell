//
//  ChoreDetailViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/15/25.
//

import SwiftUI
import Alamofire

class ChoreDetailViewModel: ObservableObject {
    @Published var historyDates: [String] = []
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
    
    func fetchHistory(for id: Int)  {
        //history 받아옴
        
        historyDates =  ["2025-04-16","2025-04-29","2025-05-01","2025-05-09","2025-05-24"]
        
        
        
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
