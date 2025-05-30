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
    @Published var isUpdateSuccess: Bool = false
    @Published var isDeleteSuccess: Bool = false
    
    
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
    
    func fetchHistory(for id: Int){
        //history 받아옴
        historyDates =  ["2025-04-16","2025-04-29","2025-05-01","2025-05-09","2025-05-14"]
        
    }
    
    func completeHistory(for id: Int, doneDate: String) async throws {
        Task {
            do {
                let body = CompleteChoreRequest(choreId: id, doneDate: doneDate)
                try await network.requestWithoutResponse(ChoreRouter.complete(body: body))
                print("🎉 complete 성공! \(doneDate)")
            }
            catch {
                print("💥 complete 실패! \(error.localizedDescription)")
            }
        }
        
        fetchHistory(for:id)
        
    }
    
    func updateChore(for id:Int) {
        let intCycledays = Int(cycleDays) ?? 1
        let reminderDays = reminderOption.getDays()
        let reminderEnabled = reminderOption == .none ? false : true
        let body = CreateChoreRequest(title: title, cycleDays: intCycledays, startDate: "2025-05-29", reminderEnabled: reminderEnabled, reminderDays: reminderDays)
        
        Task {
            do {
                try await network.requestWithoutResponse(ChoreRouter.update(id: id,body: body))
                await MainActor.run {
                    isUpdateSuccess = true
                }
                print("🎉 update 성공! \(title)")
            }
            catch {
                // Error handling
//                await MainActor.run {
//                    
//                }
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
                    isDeleteSuccess = true
                }
                print("🎉 delete 성공! \(title)")
            }
            catch {
                // Error handling
//                await MainActor.run {
//
//                }
                print("💥 delete 실패! \(error.localizedDescription)\nid: \(id)")
            }
        }
    }
}
