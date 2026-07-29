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
        calendar.timeZone = .current
        return calendar
    }
    
    private func makeDate(_ year: Int, _ month:Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    @Test
    func nextDueStrig_returnsString() {
        let start = makeDate(2026,1,1)
        let result = RecurrenceNextDueCalculator.nextDueString(for: .fixedDay([]), from: start, calendar: calendar)
        
        #expect(result == start.toString())
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
        let start1 = makeDate(2026,2,1)
        let result1 = RecurrenceNextDueCalculator.nextDueDate(for: .perMonth, from: start1, calendar:calendar)
        let start2 = makeDate(2026,1,31)
        let result2 = RecurrenceNextDueCalculator.nextDueDate(for: .perMonth, from: start2, calendar:calendar)
        
        #expect(result1 == makeDate(2026,3,1))
        #expect(result2 == makeDate(2026,2,28))
    }
    
    @Test
    func fixedDay_returnsCorrectly() {
        let monday = makeDate(2026, 7, 27) // monday
        
        let result = RecurrenceNextDueCalculator.nextDueDate(
            for: .fixedDay([.MONDAY, .FRIDAY]),
            from: monday,
            calendar: calendar
        )
        
        #expect(result == makeDate(2026, 7, 31))
    }
    
    @Test
    func fixedDate_returnsCorrectly() {
        let start1 = makeDate(2026, 7, 27)
        let start2 = makeDate(2026, 2, 20)
        
        let result1 = RecurrenceNextDueCalculator.nextDueDate(
            for: .fixedDate([.day(27), .day(1)]),
            from: start1,
            calendar: calendar
        )
        
        let result2 = RecurrenceNextDueCalculator.nextDueDate(
            for: .fixedDate([ .day(30)]),
            from: start2,
            calendar: calendar
        )
        
        #expect(result1 == makeDate(2026, 8, 1))
        #expect(result2 == makeDate(2026, 3, 30))
    }
    
    @Test
    func fixedMonth_returnsCorrectly() {
        let start = makeDate(2026, 7, 27)
        
        let result = RecurrenceNextDueCalculator.nextDueDate(
            for: .fixedMonth([.jan, .jul, .apr]),
            from: start,
            calendar: calendar
        )
        
        #expect(result == makeDate(2027, 1, 27))
    }
    
    
}
