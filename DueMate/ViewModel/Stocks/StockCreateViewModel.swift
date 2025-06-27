//
//  StockCreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/21/25.
//

import Foundation
import SwiftUI

class StockCreateViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var unitDays: Int = 3
    @Published var unitQuantity: Int = 1
    @Published var unit: String = "개"
    @Published var currentAmount: Int? = nil
    @Published var selectedReminder: ReminderOptions = .none
    @Published var isStockCreated = false
    
    let unitOptions = ["개", "ml", "L", "kg", "g", "장", "롤", "팩", "병", "캔"]
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        currentAmount != nil && currentAmount! > 0 &&
        unitDays > 0 &&
        unitQuantity > 0
    }
    
    var expectedDaysLeft: Int {
        guard let currentAmount = currentAmount , unitQuantity > 0 else { return 0 }
        return (currentAmount * unitDays) / unitQuantity
    }
    
    
    func createStock() {
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
        let body = CreateStockRequest(
            title: title,
            quantity: currentAmount ?? 0,
            unit: unit,
            unitDays: unitDays,
            unitQuantity: unitQuantity,
            reminderDays: reminderDays
        )
        
        Task {
            do {
                try await DefaultNetworkService.shared.requestWithoutResponse(StockRouter.create(body: body))
                await MainActor.run {
                    isStockCreated = true
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
