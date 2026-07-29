//
//  ChoreCreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 4/30/25.
//

import Foundation
import SwiftUI



@MainActor
class ChoreCreateViewModel: ObservableObject, ErrorReporting {
    @Published var title: String = ""
    @Published var category: String = "living"
    @Published private(set) var recurrenceDraft = ChoreRecurrenceDraft()
    
    var isFixedCycle: Bool {
        recurrenceDraft.isFixed
    }
    
    var cycleOption: CycleOption {
        recurrenceDraft.cycleOption
    }
    
    // Form Validation
    var isFormValid: Bool {
        let isTitleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        guard isTitleValid else { return false }
        
        if !isFixedCycle {
            return true
        }
        
        return recurrenceDraft.isValidForSave
        
    }
    
    var currentDraft: ChoreDraft? {
        guard isFormValid else { return nil }
        
        return ChoreDraft(
            title: title,
            category: category,
            recurrenceRule: recurrenceDraft.rule
        )
    }
    
    func setIsFixedCycle(_ isFixed: Bool) {
        recurrenceDraft.setFixed(isFixed)
    }
    
    func setCycleOption(_ option: CycleOption) {
        recurrenceDraft.setCycleOption(option)
    }
    
    func isDaySelected(_ day: DayOptions) -> Bool {
        recurrenceDraft.containsDay(day)
    }
    
    func toggleDay(_ day: DayOptions) {
        recurrenceDraft.toggleDay(day)
    }
    
    func isDateSelected(_ date: DateOptions) -> Bool {
        recurrenceDraft.containsDate(date)
    }
    
    func toggleDate(_ date: DateOptions) {
        recurrenceDraft.toggleDate(date)
    }
    
    func isMonthSelected(_ month: MonthOptions) -> Bool {
        recurrenceDraft.containsMonth(month)
    }
    
    func toggleMonth(_ month: MonthOptions) {
        recurrenceDraft.toggleMonth(month)
    }
    
    func setupForUpdate(_ item: ChoreItem){
        title = item.title
        category = item.roomCategory
        recurrenceDraft = ChoreRecurrenceDraft(rule: item.recurrenceRule ?? .perWeek)
    }
}
