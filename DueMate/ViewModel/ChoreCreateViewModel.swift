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
    @Published var selectedReminder: ReminderOptions = .none
    @Published var showPicker = false
    @Published var isChoreCreated = false
    
    
    // Form Validation
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(cycle) != nil && Int(cycle)! > 0 && Int(cycle)! <= 365
    }
    
    // - Network
    func createChore() {
        let cycleInt = Int(cycle) ?? 1
        let reminderEnabled = (selectedReminder == .none) ? false : true
        var reminderDays: Int = 0
        
        switch selectedReminder {
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
        
        
        Task {
            do {
                try await DefaultNetworkService.shared.requestWithoutResponse(ChoreRouter.create(body: body))
                await MainActor.run {
                    isChoreCreated = true
                    print("🎉 생성 완료! \(title)")
                }
            }
            catch {
//                //Error handling later
//                await MainActor.run {
//                    
//                }
                print("💥 생성 실패! \(error.localizedDescription)")
            }
            
        }
    }
    
}


