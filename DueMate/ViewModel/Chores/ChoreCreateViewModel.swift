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
        let isTitleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let isCycleValid = Int(cycle).map { $0 >= 1 && $0 <= 365 } ?? false
        return isTitleValid && isCycleValid
    }
    
    // - Network
    func createChore() {
        print("==> Creating Chore")
        let cycleInt = Int(cycle) ?? 1
        var reminderDays: Int? = 0
        
        switch selectedReminder {
        case .theDay:
            reminderDays = 0
        case .oneDayBefore:
            reminderDays = 1
        case .twoDaysBefore:
            reminderDays = 2
        case .none:
            reminderDays = nil
        }
        
        let body = CreateChoreRequest(
            title: title,
            cycleDays: cycleInt,
            startDate: DateFormatter.yyyyMMdd.string(from: startDate),
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
                if let nwError = error as? NetworkError {
                    await ErrorHandler.shared.handle(nwError)
                } else {
                    print("💥 ErrorHandling Failed:  \(error.localizedDescription)")
                }
            }
            
        }
    }
    
}


