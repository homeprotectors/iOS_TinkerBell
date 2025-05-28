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
    
    @Published var firstTitle: String = ""
    @Published var firstCycleDays: String = ""
    @Published var firstReminderOption: ReminderOptions = .none
    
    
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
        let body = CompleteChoreRequest(choreId: id, doneDate: doneDate)
        
        try await withCheckedThrowingContinuation { continuation in
            AF.request(Router.completeChore(body: body))
                .validate()
                .response { response in
                    switch response.result {
                    case .success(_):
                        print("\(self.title): \(doneDate) 완료!")
                        continuation.resume(returning: ())
                    case .failure(let error):
                        print("❌ complete failed ❌")
                        continuation.resume(throwing: error)
                    }
                }
        }
        
        fetchHistory(for:id)
        
    }
    
    func updateChore(for id:Int) async throws {
        let intCycledays = Int(cycleDays) ?? 1
        let reminderDays = reminderOption.getDays()
        let reminderEnabled = reminderOption == .none ? false : true
        
        let body = CreateChoreRequest(title: title, cycleDays: intCycledays, startDate: "2025-05-15", reminderEnabled: reminderEnabled, reminderDays: reminderDays)
        try await withCheckedThrowingContinuation {continuation in
            AF.request(Router.updateChoreItem(id: id, body: body))
                .validate()
                .responseDecodable(of: Response<UpdateChoreResponse>.self) {
                    response in
                    switch response.result {
                    case .success(let result):
                        print("업데이트 성공!\(result.message)")
                        continuation.resume(returning: ())
                    case .failure(let error):
                        print("❌ update failed ❌")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func deleteChore(id:Int) async throws {
        //for async
        try await withCheckedThrowingContinuation { continuation in
            AF.request(Router.deleteChoreItem(id: id))
                .validate()
                .response { response in
                    switch response.result {
                    case .success(_):
                        print("delete completed")
                        continuation.resume(returning: ())
                    case .failure(let error):
                        print("❌ delete failed ❌")
                        continuation.resume(throwing: error)
                    }
                }
            
        }
        
    }
}
