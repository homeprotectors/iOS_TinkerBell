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
    let recurrenceType: String
    let selectedCycle: [String]?
    let roomCategory: String
}

//Complete Chore Body
struct CompleteChoreRequest: Codable {
    let choreId: Int
    let doneDate: String    // "yyyy-MM-dd"
}


// MARK: HOME

struct HomeSection: Codable, Identifiable {
    var id: String { title }
    let title: String
    let list: [HomeItem]
}


struct HomeSectionsData: Codable {
    let sections: HomeSections
}

struct HomeSections: Codable {
    let thisWeek: HomeSectionResponse
    let nextWeek: HomeSectionResponse
    let thisMonth: HomeSectionResponse
    let nextMonth: HomeSectionResponse
    
}

struct HomeSectionResponse: Codable {
    let count: Int
    let items: [HomeItem]
}

struct HomeItem: Codable, Identifiable {
    let id: Int
    let title: String
    let recurrenceType: String?
    let selectedCycle: [String]?
    let roomCategory: String?
    let nextDue: String?
    let shoppingContainer: Bool
    let shoppingItems: [ShoppingItem]?
    
    var recurrenceRule: RecurrenceRule? {
        guard let recurrenceType else { return nil }
        return RecurrenceMapper.fromDTO(
            RecurrenceDTO(recurrenceType: recurrenceType, selectedCycle: selectedCycle)
        )
    }
    
    var recurrenceDescription: String {
        RecurrenceFormatter.displayText(recurrenceType: recurrenceType, selectedCycle: selectedCycle)
    }
}

struct ShoppingItem: Codable, Identifiable {
    let id: Int
    let name: String
    let currentQuantity: Int
    let remainingDays: Int
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
