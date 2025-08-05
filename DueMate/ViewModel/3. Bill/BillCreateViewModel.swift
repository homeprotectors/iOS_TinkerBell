//
//  BillCreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 8/1/25.
//

import Foundation
import SwiftUI

class BillCreateViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var isFixed: Bool = false
    @Published var amount: Double = 0
    @Published var dueDate: Date = Date()
    @Published var selectedReminder: ReminderOptions = .none
    
    var amountString: String {
        get { amount == 0 ? "" : "\(amount)" }
        set { amount = Double(newValue) ?? 0 }
    }
    
    var isFormValid: Bool {
        return false
    }
    
    func createBill() {
        
    }
}
