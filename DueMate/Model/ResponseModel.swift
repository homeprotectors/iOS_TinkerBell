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


//Create Response
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
    let reminderEnabled: Bool
    let reminderDays: Int
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
