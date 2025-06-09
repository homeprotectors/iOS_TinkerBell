//
//  CalendarViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import Foundation
import SwiftUI


class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var historyDates: [Date] = []
    @Published var selectedDate: Date? = nil
    @Published var nextDue: Date = Date()
    @Published var cells: [CalendarCell] = []
    
    private var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 1 // Sunday
        return calendar
    }()
    
    
    init(){
        self.selectedDate = Date().normalizedDate()
        generateCalendar()
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
    
    func generateCalendar() {
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)
        else { return }
        
        var dates: [CalendarCell] = []
        
        //start day of the month / 1 = sun / 2 = mon ... / 7 = sat
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysBefore = (firstWeekday - calendar.firstWeekday + 7) % 7
        let previousMonth = calendar.date(byAdding: .month,value: -1, to: firstDayOfMonth)!
        let previousMonthDays = calendar.range(of:.day , in:.month, for: previousMonth)!
        
        //previous month days
        if daysBefore > 0 {
            for previousDay in (previousMonthDays.count - daysBefore + 1 )...previousMonthDays.count {
                let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: previousMonth),
                                                              month: calendar.component(.month, from: previousMonth),
                                                              day: previousDay))!
                dates.append(makeCell(date: date, isInCurrentMonth: false))
            }
        }
        
        
        //current month days
        for day in range {
            let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth),
                                                          month: calendar.component(.month, from: currentMonth),
                                                          day: day))!
            dates.append(makeCell(date: date, isInCurrentMonth: true))
        }
        
        //next month days
        while dates.count % 7 != 0, let lastDate = dates.last?.date {
            let nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate)!
            dates.append(makeCell(date: nextDate, isInCurrentMonth: false))
        }
        
        cells = dates

    }
    
    private func makeCell(date: Date, isInCurrentMonth: Bool) -> CalendarCell {
        let normalizedDate = date.normalizedDate()
        return CalendarCell(
            date: normalizedDate,
            day: calendar.component(.day, from: normalizedDate),
            isInCurrentMonth: isInCurrentMonth,
            isInHistory: historyDates.contains(normalizedDate),
            isNextDue: nextDue == normalizedDate,
            isSelected: selectedDate == normalizedDate,
            isSelectable: isSelectable(date: normalizedDate))
            
    }
    
    
    func isSelectable(date: Date) -> Bool {
        let today = Date().normalizedDate()
        guard calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) else {
                return false
            }
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today)!
        return date <= today && date >= twoWeeksAgo
    }
    
    func numberOfDays(in date:Date) -> Int {
        return calendar.range(of:.day, in: .month, for:date)?.count ?? 0
    }
    
   
   
}

