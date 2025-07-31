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
    let cycleDays: Int
    let startDate: String  // "yyyy-MM-dd"
    let reminderDays: Int?
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
    let title: String
    let currentQuantity: Int
    let unit: String
    let unitDays: Int
    let unitQuantity: Int
    let reminderDays: Int?
    
    enum CodingKeys: String, CodingKey {
        case title = "name"
        case currentQuantity
        case unit
        case unitDays
        case unitQuantity
        case reminderDays
    }
}

struct UpdateStockRequest: RequestBody {
    let name: String
    let unitQuantity: Int
    let unitDays: Int
    let reminderDays:Int?
    let currentQuantity: Int
    
}
