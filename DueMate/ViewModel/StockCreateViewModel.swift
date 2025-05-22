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
    @Published var usageDays: Int = 3
    @Published var usageAmount: Int = 1
    @Published var usageUnit: String = "개"
    @Published var currentAmount: Int? = nil
    @Published var selectedReminder: alertOptions = .none
    @Published var isStockCreated = false
    
    let unitOptions = ["개", "ml", "L", "kg", "g", "장", "롤", "팩"]
    
    var isFormValid: Bool {
        return true
    }
    
    var expectedDaysLeft: Int {
        guard let currentAmount = currentAmount , usageAmount > 0 else { return 0 }
        return (currentAmount * usageDays) / usageAmount
    }
    
    
    func createStock() {
        print("Stock \(title) created! ")
    }
}
