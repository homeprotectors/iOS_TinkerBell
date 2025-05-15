//
//  ChoreCreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 4/30/25.
//

import Foundation
import SwiftUI
import Alamofire



class ChoreCreateViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var cycle: String = ""
    @Published var startDate: Date = Date()
    @Published var selectedAlert: alertOptions = .none
    @Published var showPicker = false
    @Published var isChoreCreated = false
    
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
        AF.request(Router.createChoreItem(body: body))
            .validate()
            .responseDecodable(of: Response<ChoreCreateResponseData>.self){
                response in
                switch response.result {
                case .success(let result):
                    print("성공!✅ \(result.message)")
                    self.isChoreCreated = true
                    
                case .failure(let error):
                    print("에러🚩 \(error.localizedDescription)")
                }
            }
    }
    
}



