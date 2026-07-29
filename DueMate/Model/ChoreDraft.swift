//
//  ChoreDraft.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Foundation

struct ChoreDraft: Equatable {
    let title: String
    let category: String
    let recurrenceRule: RecurrenceRule
    
    var normalizedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var recurrenceDTO: RecurrenceDTO {
        RecurrenceMapper.toDTO(recurrenceRule)
    }
    
    var createRequest: CreateChoreRequest {
        CreateChoreRequest(
            title: normalizedTitle,
            recurrenceType: recurrenceDTO.recurrenceType,
            selectedCycle: recurrenceDTO.selectedCycle,
            roomCategory: category.uppercased()
        )
    }
    
    var updateRequest: UpdateChoreRequest {
        UpdateChoreRequest(
            title: normalizedTitle,
            recurrenceType: recurrenceDTO.recurrenceType,
            selectedCycle: recurrenceDTO.selectedCycle,
            roomCategory: category.uppercased()
        )
    }
    
    func makeLocalItem(id: Int, nextDue: String? = nil) -> ChoreItem {
        ChoreItem(
            id: id,
            title: normalizedTitle,
            recurrenceType: recurrenceDTO.recurrenceType,
            selectedCycle: recurrenceDTO.selectedCycle,
            roomCategory: category.lowercased(),
            nextDue: nextDue ?? RecurrenceNextDueCalculator.nextDueString(for: recurrenceRule)
        )
    }
}
