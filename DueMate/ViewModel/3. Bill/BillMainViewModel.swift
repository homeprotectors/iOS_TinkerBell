//
//  BillMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 8/5/25.
//

import Foundation
import SwiftUI

class BillMainViewModel: ObservableObject {
    @Published var items: [SectionItem<BillItem>] = []
    @Published var sections: BillSection = BillSection(fixed: [], variable: [])
    @Published var currentMonth: Date = Date()
    @Published var total: Double = 120000000
    @Published var difference: Double =  0
    
    private let network = DefaultNetworkService.shared
    
    var monthInt: Int {
        Calendar.current.component(.month, from: currentMonth)
    }
    var currentMonthString: String {
        currentMonth.toYearMonth()
    }
    
    var isCurrentMonth: Bool {
        let now = Date()
        let cal = Calendar.current
        return cal.component(.year, from: now) == cal.component(.year, from: currentMonth)
            && cal.component(.month, from: now) == cal.component(.month, from: currentMonth)
    }
    
    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
        fetchBills()
    }
    
    func fetchBills() {
        sections.fixed = [
            BillItem(id: 1, name: "넷플릭스", isVariable: false, isPaid: false, amount: 24000, dueDate: 15)
        ]
        sections.variable = [
            BillItem(id: 2, name: "가스비", isVariable: true, isPaid: false, amount: 50000, dueDate: 1),
            BillItem(id: 3, name: "전기세", isVariable: true, isPaid: false, amount: 70000, dueDate: 12)
        ]
        
        //
//        Task {
//            do {
//                let itemsResponse: MonthlyBill = try await network.request(BillRouter.getItems)
//                
//                await MainActor.run {
//                    self.items = [SectionItem(header: "변동금액", list: itemsResponse.sections.variable),
//                                  SectionItem(header: "고정금액", list: itemsResponse.sections.fixed)]
//                    self.total = itemsResponse.monthTotal
//                    self.difference = itemsResponse.difference
//                    
//                }
//                print("🎉 Bill fetch 성공!")
//            } catch {
//                await MainActor.run {
//                    if let networkError = error as? NetworkError {
//                        ErrorHandler.shared.handle(networkError)
//                    } else {
//                        ErrorHandler.shared.handle(NetworkError.unknown(error))
//                    }
//                }
//                print("💥 Bill fetch 실패!  \(error.localizedDescription)")
//            }
//        }
//        
        
        items = [
            SectionItem(header: "변동금액", list: sections.variable),
            SectionItem(header: "고정금액", list: sections.fixed)
        ]
        
    }
    
    func updateVariableBill(id: Int, amount: Double) {
        print("\(id): \(amount)")
    }
    
    func deleteBill(id: Int){
        
    }
}
