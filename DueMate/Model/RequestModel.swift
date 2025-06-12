//
//  RequestModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/5/25.
//

import Foundation

protocol RequestBody: Codable {}

//Create Chore Request Body
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
