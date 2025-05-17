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
    @Published var reminderOption: alertOptions = .none
    
    @Published var firstTitle: String = ""
    @Published var firstCycleDays: String = ""
    @Published var firstReminderOption: alertOptions = .none
    
    
    func fetchHistory(for id: Int){
        //history 받아옴
        historyDates =  ["2025-04-16","2025-04-29","2025-05-01","2025-05-09","2025-05-14"]
        
    }
    
    func firstInputSetting(title: String, cycleDays: String, reminderOption: alertOptions) {
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
    
    func updateChore(for id:Int) async throws {
        let intCycledays = Int(cycleDays) ?? 1
        let reminderDays = reminderOption.getDays()
        let reminderEnabled = reminderOption == .none ? false : true
        
        
        let body = CreateChoreRequest(title: title, cycleDays: intCycledays, startDate: "2025-05-15", reminderEnabled: reminderEnabled, reminderDays: reminderDays)
        try await withCheckedThrowingContinuation {continuation in
            AF.request(Router.updateChoreItem(id: id, body: body))
                .validate()
                .responseDecodable(of: Response<ChoreUpdateResponseData>.self) {
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
