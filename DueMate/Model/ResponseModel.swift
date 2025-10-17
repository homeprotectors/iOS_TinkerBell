//
//  ResponseModel.swift
//  DueMate
//
//  Created by Kacey Kim on 4/29/25.
//

import Foundation


struct Response<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}

// MARK: HOME
struct HomeItem: Codable, Identifiable {
    let id: Int
    let title: String
    let status: String
    let category: String
    let cycle: String
    let shoppingList: [ShoppingItem]?
}

struct ShoppingItem: Codable, Identifiable {
    let id: Int
    let name: String
    let currentQuantity: Int
}

struct HomeSection: Codable, Identifiable {
    let id: Int
    let list: [HomeItem]
}

// MARK: Chore
struct CreateChoreResponse: Codable {
    let id: Int
    let title: String
    let cycleDays: Int
    let reminderEnabled: Bool
    let reminderDays: Int
}

struct UpdateChoreResponse: Codable {
    let id: Int
    let title: String
    let startDate: String
    let cycleDays: Int
    let reminderEnabled: Bool
    let reminderDays: Int
}


//Get chore list item
struct ChoreItem: Codable, Identifiable {
    let id: Int
    let title: String
    let cycleDays: Int
    let nextDue: String
    let reminderDays: Int?
}

// Responses for updating Chore History : not using at the moment
struct CompleteChoreHistoryResponse: Codable {
    let id: Int
    let newNextDue: String
    let newReminderDate: String
    let doneBy: Int
}

struct UndoChoreHistoryResponse: Codable {
    let choreId: Int
    let nextDue: String
    let reminderDate: String
    let lastDone: String
}

struct GetChoreHistoryResponse: Codable {
    let choreId: Int
    let nextDue: String
    let history: [ChoreHistory]
}

struct ChoreHistory: Codable, Equatable {
    let id: Int
    let doneDate: String
    let doneBy: Int
}

// MARK: Stock

struct StockItem: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let unitDays: Int   //며칠에
    let unitQuantity: Int //몇개
    var currentQuantity: Int
    let remainingDays: Int
}

struct StockItemTemp: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let unitDays: Int   //며칠에
    let unitQuantity: Int //몇개
    var updatedQuantity: Int
}

struct CreateStockResponse: Codable {
    let id: Int
    let name: String
    let unitDays: Int
    let unitQuantity: Int
    let updatedQuantity: Int
}

// MARK: Bill

struct BillItem: Codable, Identifiable {
    let id: Int
    let title: String
    let isFixed: Bool
    let isPaid: Bool
    let amount: Double
    let dueDate: Int
    let reminderDays: Int?
}

struct CreateBillResponse: Codable{
    let billId: Int
    let name: String
    let amount: Double
    let dueDate: Int
    let isVariable: Bool
    let reminderDays: Int?
}
