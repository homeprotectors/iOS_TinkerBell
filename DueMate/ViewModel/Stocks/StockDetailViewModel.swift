//
//  StockDetailViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 7/11/25.
//

import Foundation
import Alamofire

class StockDetailViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var unitDays: Int = 3
    @Published var unitQuantity: Int = 1
    @Published var unit: String = ""
    @Published var reminderOptions: ReminderOptions = .none
    @Published var shoudRedirectMain: Bool = false
    
    @Published var firstTitle: String = ""
    @Published var firstUnitDays: Int = 3
    @Published var firstUnitQuantity: Int = 1
    @Published var firstUnit: String = ""
    @Published var firstReminderOption: ReminderOptions = .none
    
    var unitQuantityString: String {
        get { String(unitQuantity) }
        set { unitQuantity = Int(newValue) ?? 1}
    }
    
    var unitDaysString: String {
        get { String(unitDays) }
        set { unitDays = Int(newValue) ?? 1 }
    }
    
    
    private let network = DefaultNetworkService.shared
    
    func firstInputSetting(item: StockItem) {
        self.title = item.title
        self.unitDays = item.unitDays
        self.unitQuantity = item.unitQuantity
        self.unit = item.unit
        
        
        firstTitle = title
        firstUnitDays = unitDays
        firstUnitQuantity = unitQuantity
        firstUnit = unit
        
    }
    
    func hasInputChanged() -> Bool {
        return title != firstTitle || unitDays != firstUnitDays || unitQuantity != firstUnitQuantity || unit != firstUnit || reminderOptions != firstReminderOption
    }
}

