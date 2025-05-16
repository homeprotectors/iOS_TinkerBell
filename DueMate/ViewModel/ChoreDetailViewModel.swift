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
    @Published var selectedAlert: alertOptions = .none
    
    
    
    func fetchHistory(for id: Int){
        //history 받아옴
        historyDates =  ["2025-04-16","2025-04-29","2025-05-01","2025-05-09","2025-05-14"]
        
    }
    
    func updateChore(for id:Int) async throws {
        let intCycledays = Int(cycleDays) ?? 0
        var reminderEnabled = true
        var reminderDays = 0
        switch selectedAlert {
        case .theDay:
            reminderDays = 0
        case .oneDayBefore:
            reminderDays = 1
        case .twoDaysBefore:
            reminderDays = 2
        case .none:
            reminderDays = 0
            reminderEnabled = false
        }
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
