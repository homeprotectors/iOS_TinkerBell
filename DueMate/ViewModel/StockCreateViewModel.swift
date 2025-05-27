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
    @Published var consumptionDays: Int = 3
    @Published var consumptionAmount: Int = 1
    @Published var consumptionUnit: String = "개"
    @Published var currentAmount: Int? = nil
    @Published var selectedReminder: ReminderOptions = .none
    @Published var isStockCreated = false
    
    let unitOptions = ["개", "ml", "L", "kg", "g", "장", "롤", "팩", "병", "캔"]
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        currentAmount != nil && currentAmount! > 0 &&
        consumptionDays > 0 &&
        consumptionAmount > 0
    }
    
    var expectedDaysLeft: Int {
        guard let currentAmount = currentAmount , consumptionAmount > 0 else { return 0 }
        return (currentAmount * consumptionDays) / consumptionAmount
    }
    
    
    func createStock() {
        print("Stock \(title) created! ")
    }
}
