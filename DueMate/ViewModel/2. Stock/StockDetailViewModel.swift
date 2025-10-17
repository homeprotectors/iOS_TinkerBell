//
//  StockDetailViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 7/11/25.
//

import Foundation
import Alamofire

class StockDetailViewModel: ObservableObject {
    private let network = DefaultNetworkService.shared
    
    @Published var title: String = ""
    @Published var unitDays: Int = 3
    @Published var unitQuantity: Int = 1
    @Published var currentQuantity: Int = 0
    @Published var reminderOption: ReminderOptions = .none
    @Published var shoudRedirectMain: Bool = false
    
    @Published var firstTitle: String = ""
    @Published var firstUnitDays: Int = 3
    @Published var firstUnitQuantity: Int = 1
    @Published var firstUnit: String = ""
    @Published var firstCurrentQuantity: Int = 0
    @Published var firstReminderOption: ReminderOptions = .none
    
    var unitQuantityString: String {
        get { String(unitQuantity) }
        set { unitQuantity = Int(newValue) ?? 1}
    }
    
    var unitDaysString: String {
        get { String(unitDays) }
        set { unitDays = Int(newValue) ?? 1 }
    }
    
    var currentQuantityString: String {
        get { String(currentQuantity) }
        set { currentQuantity = Int(newValue) ?? 0}
    }
   

    
    func deleteStock(id: Int) {
        print("Delete Stock ::: \(id) - \(title)")
        Task {
            do {
                try await network.requestWithoutResponse(StockRouter.delete(id: id))
                await MainActor.run {
                    shoudRedirectMain = true
                }
                print("🎉 delete 성공! \(title)")
            }
            catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 delete 실패! \(error.localizedDescription)\nid: \(id)")
            }
        }
    }
    
    
    func firstInputSetting(item: StockItem) {
        self.title = item.name
        self.unitDays = item.unitDays
        self.unitQuantity = item.unitQuantity
        
        self.currentQuantity = item.currentQuantity
        self.currentQuantity = item.currentQuantity
        
        firstTitle = title
        firstUnitDays = unitDays
        firstUnitQuantity = unitQuantity
        
        firstCurrentQuantity = currentQuantity
        
    }
    
    func hasInputChanged() -> Bool {
//        return title != firstTitle || unitDays != firstUnitDays || unitQuantity != firstUnitQuantity || unit != firstUnit || reminderOption != firstReminderOption || currentQuantity != firstCurrentQuantity
        return false
    }
}

