//
//  RecurrenceNextDueCalculatorTests.swift
//  DueMateTests
//
//  Created by Kacey Kim on 7/28/26.
//

import Foundation
import Testing
@testable import DueMate


struct RecurrenceNextDueCalculatorTests {
    // date setting helper
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    
    private func makeDate(_ year: Int, _ month:Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    
    @Test
    func perWeek_returns7DaysLater() {
        let start = makeDate(2026,1,1)
        let result = RecurrenceNextDueCalculator.nextDueDate(for: .perWeek, from: start, calendar:calendar)
        
        #expect(result == makeDate(2026,1,8))
    }
    
    @Test
    func per2Weeks_returns14DaysLater() {
        let start = makeDate(2026,1,1)
        let result = RecurrenceNextDueCalculator.nextDueDate(for: .per2Weeks, from: start, calendar:calendar)
        
        #expect(result == makeDate(2026,1,15))
    }
    
    @Test
    func perMonth_returnsOneMonthLater() {
        let start = makeDate(2026,2,1)
        let result = RecurrenceNextDueCalculator.nextDueDate(for: .perMonth, from: start, calendar:calendar)
        
        #expect(result == makeDate(2026,3,1))
    }
    
    @Test
    func fixedDay_returnsCorrectly() {
        let monday = makeDate(2026, 7, 27) // monday
        
        let result = RecurrenceNextDueCalculator.nextDueDate(
            for: .fixedDay([.MONDAY, .FRIDAY]),
            from: monday,
            calendar: calendar
        )
        
        #expect(result == makeDate(2026, 7, 27))
    }
}
