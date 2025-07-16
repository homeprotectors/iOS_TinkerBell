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
    @Published var currentQuantity: Int? = nil
    @Published var selectedReminder: ReminderOptions = .none
    @Published var isStockCreated = false
    
    var unitDaysString: String {
        get { String(unitDays) }
        set { unitDays = Int(newValue) ?? 1 }
    }
    
    var unitQuantityString: String {
        get { String(unitQuantity) }
        set { unitQuantity = Int(newValue) ?? 1 }
    }
    
    var currentQuantityString: String {
        get { currentQuantity.map(String.init) ?? "" }
        set { currentQuantity = Int(newValue) ?? 1 }
    }
    
    let unitOptions = ["개", "ml", "L", "kg", "g", "장", "롤", "팩", "병", "캔"]
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        currentQuantity != nil && currentQuantity! > 0 &&
        unitDays > 0 &&
        unitQuantity > 0
    }
    
    var expectedDaysLeft: Int {
        guard let currentAmount = currentQuantity , unitQuantity > 0 else { return 0 }
        return (currentAmount * unitDays) / unitQuantity
    }
    
    
    func createStock() {
        let body = CreateStockRequest(
            title: title,
            quantity: currentQuantity ?? 0,
            unit: unit,
            unitDays: unitDays,
            unitQuantity: unitQuantity,
            reminderDays: selectedReminder.getDays()
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
