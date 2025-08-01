//
//  CalendarViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import Foundation
import SwiftUI


class CalendarViewModel: ObservableObject {
    @Published private(set) var currentMonth: Date = Date()
    @Published private(set) var cells: [CalendarCell] = []
    @Published var selectedDate: Date? = nil
    @Published var historyDates: [Date] = []
    @Published var nextDue: Date = Date()
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 1
        return calendar
    }()
    
    private let today = Date().normalizedDate()
    private var twoWeeksAgo: Date {
        calendar.date(byAdding: .day, value: -14, to: today) ?? today
    }
    
    var weekdaySymbols: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year,.month], from: currentMonth))!
    }
    
    var isNextMonthAvaliable: Bool {
        guard let now = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) else {
            return false
        }
        return currentMonth < now
    }
    
    var isPreviousMonthAvaliable: Bool {
        //sort history and compare to the earliest history
        return true
    }
    
    init(){
        self.selectedDate = Date().normalizedDate()
        generateCalendar()
    }
    
    func generateCalendar() {
        // 현재 달 범위
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return }
        // 달의 1일
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        // 1일의 요일 : 1(Sun) 2(Mon) 3(Tue) 4(Wed) 5(Thu) 6(Fri) 7(Sat)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysInMonth = range.count
        var cells: [CalendarCell] = []
        let daysBefore = firstWeekday - 1
        if daysBefore > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            for day in (daysInPreviousMonth - daysBefore + 1)...daysInPreviousMonth {
                let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: previousMonth), month: calendar.component(.month, from: previousMonth), day: day))!
                cells.append(CalendarCell(date: date.normalizedDate(), day: day, isInCurrentMonth: false, isSelectable: isDateSelectable(date.normalizedDate())))
            }
        }
        for day in 1...daysInMonth {
            let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth), month: calendar.component(.month, from: currentMonth), day: day))!
            cells.append(CalendarCell(date: date.normalizedDate(), day: day, isInCurrentMonth: true, isSelectable: isDateSelectable(date.normalizedDate())))
        }
        let remainingDays = 7 - (cells.count % 7)
        if remainingDays != 7 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
            for day in 1...remainingDays {
                let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: nextMonth), month: calendar.component(.month, from: nextMonth), day: day))!
                cells.append(CalendarCell(date: date.normalizedDate(), day: day, isInCurrentMonth: false, isSelectable: isDateSelectable(date.normalizedDate())))
            }
        }
        self.cells = cells
    }
    
    private func isDateSelectable(_ date: Date) -> Bool {
        date <= today && date >= twoWeeksAgo
    }
    
    func goToPreviousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        selectedDate = nil
        generateCalendar()
    }
    
    func goToNextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        selectedDate = nil
        generateCalendar()
    }
    
    func loadHistory(_ histories: [ChoreHistory]) {
        self.historyDates = histories
            .map(\.doneDate)
            .compactMap { DateFormatter.yyyyMMdd.date(from: $0) }
        generateCalendar()
    }
    
    func numberOfDays(in date:Date) -> Int {
        return calendar.range(of:.day, in: .month, for:date)?.count ?? 0
    }
}

