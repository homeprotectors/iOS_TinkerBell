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
    @Published var amount: Double = 0
    @Published var dueDate: Int = 0
    @Published var selectedReminder: ReminderOptions = .none
    @Published var isBillCreated = false
    
    var amountString: String {
        get { amount == 0 ? "" : "\(amount)" }
        set { amount = Double(newValue) ?? 0 }
    }
    
    var dueDateString: String {
        get { dueDate == 0 ? "" : "\(dueDate)" }
        set { dueDate = Int(newValue) ?? 0 }
    }
    
    var isFormValid: Bool {
        let isTitleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        return isTitleValid && amount > 0 && dueDate > 0 && dueDate < 32
    }
    
    func createBill() {
        let body = CreateBillRequest(name: title, amount: 20000, dueDate: 1, isVariable: isVariable, reminderDays: selectedReminder.getDays())
        print("📤 요청 전송: \(body)")
    
        
        Task {
            do {
                try await DefaultNetworkService.shared.requestWithoutResponse(BillRouter.create(body: body))
                
                await MainActor.run {
                    isBillCreated = true
                    print("🎉 생성 완료! \(title)")
                    
                }
            }
            catch {
                // 에러 발생 시 실제 서버 응답 확인
                print("🚨 에러 발생: \(error)")
                
                if let nwError = error as? NetworkError {
                    await ErrorHandler.shared.handle(nwError)
                } else {
                    print("💥 ErrorHandling Failed: \(error.localizedDescription)")
                }
                
                // 실제 서버 응답 로그
                Task {
                    do {
                        let rawResponse = try await AF.request(BillRouter.create(body: body))
                            .serializingString()
                            .value
                        print("📥 서버 응답 (raw): \(rawResponse)")
                    } catch {
                        print("📥 응답 로그 실패: \(error)")
                    }
                }
            }
        }
        
    }
}
