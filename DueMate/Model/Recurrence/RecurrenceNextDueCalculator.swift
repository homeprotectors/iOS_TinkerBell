//
//  RecurrenceNextDueCalculator.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Foundation

enum RecurrenceNextDueCalculator {
    static func nextDueString(
        for rule: RecurrenceRule,
        from referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        guard let nextDueDate = nextDueDate(for: rule, from: referenceDate, calendar: calendar) else {
            return calendar.startOfDay(for: referenceDate).toString()
        }
        
        return nextDueDate.toString()
    }
    
    static func nextDueDate(
        for rule: RecurrenceRule,
        from referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        let referenceDay = calendar.startOfDay(for: referenceDate)
        
        switch rule {
        case .perWeek:
            return calendar.date(byAdding: .day, value: 7, to: referenceDay)
        case .per2Weeks:
            return calendar.date(byAdding: .day, value: 14, to: referenceDay)
        case .perMonth:
            return calendar.date(byAdding: .month, value: 1, to: referenceDay)
        case .fixedDay(let days):
            return nextFixedDay(from: referenceDay, days: days, calendar: calendar)
        case .fixedDate(let dates):
            return nextFixedDate(from: referenceDay, dates: dates, calendar: calendar)
        case .fixedMonth(let months):
            return nextFixedMonth(from: referenceDay, months: months, calendar: calendar)
        }
    }
    
    private static func nextFixedDay(
        from referenceDay: Date,
        days: Set<DayOptions>,
        calendar: Calendar
    ) -> Date? {
        guard !days.isEmpty else { return nil }
        
        let selectedWeekdays = Set(days.map(weekdayValue(for:)))
        for offset in 0...14 {
            guard let candidate = calendar.date(byAdding: .day, value: offset, to: referenceDay) else {
                continue
            }
            
            if selectedWeekdays.contains(calendar.component(.weekday, from: candidate)) {
                return candidate
            }
        }
        
        return nil
    }
    
    private static func nextFixedDate(
        from referenceDay: Date,
        dates: Set<DateOptions>,
        calendar: Calendar
    ) -> Date? {
        guard !dates.isEmpty else { return nil }
        
        let sortedDates = dates.sorted(by: sortDateOptions)
        for monthOffset in 0...12 {
            guard let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: referenceDay) else {
                continue
            }
            
            for option in sortedDates {
                guard let candidate = makeDate(for: option, in: monthDate, calendar: calendar) else {
                    continue
                }
                
                if candidate >= referenceDay {
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    private static func nextFixedMonth(
        from referenceDay: Date,
        months: Set<MonthOptions>,
        calendar: Calendar
    ) -> Date? {
        guard !months.isEmpty else { return nil }
        
        let sortedMonths = months.compactMap { Int($0.rawValue) }.sorted()
        let referenceComponents = calendar.dateComponents([.year, .day], from: referenceDay)
        let referenceYear = referenceComponents.year ?? calendar.component(.year, from: referenceDay)
        let referenceDayOfMonth = referenceComponents.day ?? 1
        
        for yearOffset in 0...2 {
            let year = referenceYear + yearOffset
            
            for month in sortedMonths {
                let lastDay = daysInMonth(year: year, month: month, calendar: calendar)
                let clampedDay = min(referenceDayOfMonth, lastDay)
                let components = DateComponents(year: year, month: month, day: clampedDay)
                
                guard let candidate = calendar.date(from: components),
                      candidate >= referenceDay else {
                    continue
                }
                
                return candidate
            }
        }
        
        return nil
    }
    
    private static func makeDate(
        for option: DateOptions,
        in monthDate: Date,
        calendar: Calendar
    ) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        guard let year = components.year,
              let month = components.month else {
            return nil
        }
        
        let day: Int
        switch option {
        case .day(let value):
            let lastDay = daysInMonth(year: year, month: month, calendar: calendar)
            guard value <= lastDay else { return nil }
            day = value
        case .endOfMonth:
            day = daysInMonth(year: year, month: month, calendar: calendar)
        }
        
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }
    
    private static func daysInMonth(year: Int, month: Int, calendar: Calendar) -> Int {
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))
        return date.flatMap { calendar.range(of: .day, in: .month, for: $0)?.count } ?? 30
    }
    
    private static func weekdayValue(for option: DayOptions) -> Int {
        switch option {
        case .SUNDAY: return 1
        case .MONDAY: return 2
        case .TUESDAY: return 3
        case .WEDNESDAY: return 4
        case .THURSDAY: return 5
        case .FRIDAY: return 6
        case .SATURDAY: return 7
        }
    }
    
    private static func sortDateOptions(lhs: DateOptions, rhs: DateOptions) -> Bool {
        switch (lhs, rhs) {
        case (.endOfMonth, .endOfMonth):
            return false
        case (.endOfMonth, .day):
            return false
        case (.day, .endOfMonth):
            return true
        case let (.day(a), .day(b)):
            return a < b
        }
    }
}
