//
//  ChoreModel.swift
//  DueMate
//
//  Created by Kacey Kim on 10/18/25.
//

import Foundation

struct ChoreItem: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let recurrenceType: String
    let selectedCycle: [String]?
    let roomCategory: String
    let nextDue: String

    
    var recurrenceDescription: String {
        RecurrenceFormatter.displayText(recurrenceType: recurrenceType, selectedCycle: selectedCycle)
    }
    
    var recurrenceRule: RecurrenceRule? {
        RecurrenceMapper.fromDTO(
            RecurrenceDTO(recurrenceType: recurrenceType, selectedCycle: selectedCycle)
        )
    }
    
}

extension ChoreItem {
    init(from item: ChoreItemResponse) {
        self.id = item.id
        self.title = item.title
        self.recurrenceType = item.recurrenceType
        self.selectedCycle = item.selectedCycle
        self.roomCategory = item.roomCategory.lowercased()
        self.nextDue = item.nextDue
    }
}
