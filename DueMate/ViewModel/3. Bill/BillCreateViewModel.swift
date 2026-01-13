//
//  BillCreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 8/1/25.
//

import Foundation
import SwiftUI
import Alamofire

class BillCreateViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var isVariable: Bool = false
    @Published var amount: Int? = nil
    @Published var dueDate: Int = 0
    @Published var selectedReminder: ReminderOptions = .none
    @Published var isBillCreated = false
    

    
    var isFormValid: Bool {
        let isTitleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        guard let amount = amount else { return false }
        
        return isTitleValid && amount > 0 && dueDate != 0
    }
    
    func setUp(item: BillItem) {
        title = item.name
        isVariable = item.isVariable
        amount = Int(item.amount)
        dueDate = item.dueDate
        
    }
    
    func createBill() {
        
        let body = CreateBillRequest(name: title, amount: Double(amount ?? 0), dueDate: 1, isVariable: isVariable)
    
        
        Task {
            do {
                try await DefaultNetworkService.shared.requestWithoutResponse(BillRouter.create(body: body))
                
                await MainActor.run {
                    isBillCreated = true
                    print("🎉 생성 완료! \(title)")
                    
                }
            }
            catch {
                await MainActor.run {
                    ErrorHandler.shared.handle(error)
                }
            }
        }
        
    }
}
