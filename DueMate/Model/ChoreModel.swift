//
//  ChoreModel.swift
//  DueMate
//
//  Created by Kacey Kim on 11/8/25.
//

import Foundation



// MARK: Chore
struct CreateChoreRequest: Codable {
    let title: String
    let recurrenceType: String
    let selectedCycle: [String]?
    let roomCategory: String
}

struct UpdateChoreRequest: Codable {
    let title: String
    let cycleDays: Int
    let reminderDays: Int?
}

//Complete Chore Body
struct EditChoreHistoryRequest: Codable {
    let choreId: Int
    let doneDate: String    // "yyyy-MM-dd"
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
struct ChoreItemResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let recurrenceType: String
    let selectedCycle: [String]?
    let roomCategory: String
    let nextDue: String
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
