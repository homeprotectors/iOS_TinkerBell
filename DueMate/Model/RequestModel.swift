//
//  RequestModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/5/25.
//

import Foundation

protocol RequestBody: Codable {}

// MARK: Chore
struct CreateChoreRequest: RequestBody {
    let title: String
    
}

struct UpdateChoreRequest: RequestBody {
    let title: String
    let cycleDays: Int
    let reminderDays: Int?
}

//Complete Chore Body
struct EditChoreHistoryRequest: RequestBody {
    let choreId: Int
    let doneDate: String    // "yyyy-MM-dd"
}

// MARK: Stock
struct CreateStockRequest: RequestBody {
    let name: String
    let updatedQuantity: Int
    let unitDays: Int
    let unitQuantity: Int
}

struct UpdateStockRequest: RequestBody {
    let name: String
    let unitQuantity: Int
    let unit: String
    let unitDays: Int
    let reminderDays:Int?
    let updatedQuantity: Int   
}

struct UpdateQuantityRequest: RequestBody {
    let updatedQuantity: Int
}

// MARK: Bill

struct CreateBillRequest: RequestBody {
    let name: String
    let amount: Double
    let dueDate: Int
    let isVariable: Bool
    let reminderDays: Int?
}
