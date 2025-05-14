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
    @Published var selectedDate: Date = Date()
    
    private var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 1 // Sunday
        return calendar
    }()
    
    @Published var nextDue: Date = Date()
    @Published var cells: [CalendarCell] = []
    
    
    
    init(){
        generateCalendar()
    }
    
    var weekdaySymbols: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }

    func goToPreviousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        generateCalendar()
    }

    func goToNextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        generateCalendar()
    }
    func loadHistory(_ dateStrings: [String]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.historyDates = dateStrings.compactMap { formatter.date(from: $0) }
    }
    
    func generateCalendar() {
        guard let firstDayofMonth = calendar.date(from: calendar.dateComponents([.year,.month], from: currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: firstDayofMonth)
        else { return }
        
        var dates: [CalendarCell] = []
        
        //start day of the month / 1 = sun / 2 = mon ... / 7 = sat
        let firstWeekday = calendar.component(.weekday, from: firstDayofMonth)
        let daysBefore = (firstWeekday - calendar.firstWeekday + 7) % 7
        let previousMonth = calendar.date(byAdding: .month,value: -1, to: firstDayofMonth)!
        let previousMonthDays = calendar.range(of:.day , in:.month, for: previousMonth)!
        
        //previous month days
        for previousDay in (previousMonthDays.count - daysBefore + 1 )...previousMonthDays.count {
            let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: previousMonth),
                                                          month: calendar.component(.month, from: previousMonth),
                                                          day: previousDay))!
            dates.append(makeCell(date: date, isInCurrentMonth: false))
        }
        
        //current month days
        for day in range {
            let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth),
                                                          month: calendar.component(.month, from: currentMonth),
                                                          day: day))!
            dates.append(makeCell(date: date, isInCurrentMonth: true))
        }
        
        //next month days
        while dates.count % 7 != 0 {
            let lastDate = dates.last!.date
            let nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate)!
            dates.append(makeCell(date: nextDate, isInCurrentMonth: false))
        }
        
        
        cells = dates

    }
    
    private func makeCell(date: Date, isInCurrentMonth: Bool) -> CalendarCell {
        
        return CalendarCell(
            date: date,
            day: calendar.component(.day, from: date),
            isInCurrentMonth: isInCurrentMonth,
            isInHistory: historyDates.contains(date),
            isNextDue: nextDue == date,
            isSelected: selectedDate == date)
    }
    
    
    
    
    func isSelectable(date: Date) -> Bool {
        guard calendar.isDate(date, equalTo: Date(), toGranularity: .month) ||
                date < Date() else { return false }
        
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
        return date >= twoWeeksAgo && date <= Date()
    }
    
    func numberOfDays(in date:Date) -> Int {
        return Calendar.current.range(of:.day, in: .month, for:date)?.count ?? 0
    }
    
   
   
}

