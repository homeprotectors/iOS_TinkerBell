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
    @Published var unitDays: Int = 0
    @Published var unitQuantity: Int = 0
    @Published var unit: String = "개"
    @Published var currentQuantity: Int = 0
    @Published var selectedReminder: ReminderOptions = .none
    @Published var isStockCreated = false
    
    private var originalItem: StockItem?
    
    var unitDaysString: String {
        get { unitDays == 0 ? "" : "\(unitDays)" }
        set { unitDays = Int(newValue) ?? 0 }
    }
    
    var unitQuantityString: String {
        get { unitQuantity == 0 ? "" : "\(unitQuantity)" }
        set { unitQuantity = Int(newValue) ?? 0 }
    }
    
    var currentQuantityString: String {
        get { currentQuantity == 0 ? "" : "\(currentQuantity)" }
        set { currentQuantity = Int(newValue) ?? 0  }
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        unitDays > 0 &&
        unitQuantity > 0
    }
    
    var expectedDaysLeft: Int {
        if unitQuantity <= 0 { return 0 }
        return (currentQuantity * unitDays) / unitQuantity
    }
    
    func setupForUpdate(_ item: StockItem) {
        originalItem = item
        title = item.name
        unitDays = item.unitDays
        unitQuantity = item.unitQuantity
        currentQuantity = item.currentQuantity
    }
}
