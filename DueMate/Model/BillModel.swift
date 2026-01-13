//
//  BillModel.swift
//  DueMate
//
//  Created by Kacey Kim on 11/8/25.
//

import Foundation

struct CreateBillRequest: Codable {
    let name: String
    let amount: Double
    let dueDate: Int
    let isVariable: Bool
}

struct CreateBillResponse: Codable {
    let billId: Int
    let name: String
    let amount: Double
    let dueDate: Int
    let isVariable: Bool
}


struct BillItem: Codable, Identifiable {
    let id: Int
    let name: String
    let isVariable: Bool
    let isPaid: Bool
    let amount: Double
    let dueDate: Int
}

// Bill Section

struct MonthlyBill: Codable {
    let month: String
    let totalCount: Int
    let monthTotal: Double
    let difference: Double
    let sections: BillSection
}

struct BillSection: Codable {
    var fixed: [BillItem]
    var variable: [BillItem]
}

// Variable bill payment

struct CreateBillPayment: Codable {
    let id: Int
    let month: String
    let amount: Double
}
