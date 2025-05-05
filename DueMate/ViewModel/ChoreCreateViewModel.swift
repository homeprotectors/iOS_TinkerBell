//
//  CreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 4/30/25.
//

import Foundation
import SwiftUI
import Alamofire


extension ChoreCreateView{
    @Observable
    class ViewModel {
        var title: String = ""
        var cycle: String = ""
        var startDate: Date = Date()
        var selectedAlert: alertOptions = .none
        var showPicker = false
        
        // - Network
        func createChore() {
            let cycleInt = Int(cycle) ?? 1
            let reminderEnabled = (selectedAlert == .none) ? false : true
            var reminderDays: Int = 0
            
            switch selectedAlert {
            case .theDay:
                reminderDays = 0
            case .oneDayBefore:
                reminderDays = 1
            case .twoDaysBefore:
                reminderDays = 2
            case .none:
                reminderDays = 0
            }
            
            
            let body = CreateChoreRequest(
                    title: title,
                    cycleDays: cycleInt,
                    startDate: DateFormatter.yyyyMMdd.string(from: startDate),
                    reminderEnabled: reminderEnabled,
                    reminderDays: reminderDays
                )
            
            print("✨New Chore----------\n",body)
            AF.request(
                Router.createChoreItem(body: body))
            .responseData { response in
                debugPrint("RAW response:")
                debugPrint(response)
                
                if let data = response.data {
                    print("🔵 Response string:")
                    print(String(data: data, encoding: .utf8) ?? "nil")
                }
            }
            .responseDecodable(of: Response<ChoreCreateResponseData>.self){
                response in
                switch response.result {
                case .success(let result):
                    print("성공!✅ \(result.message)")
                case .failure(let error):
                    print("에러🚩 \(error.localizedDescription)")
                }
            }
        }
        
    }
    
}

