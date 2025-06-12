//
//  Date+Extension.swift
//  DueMate
//
//  Created by Kacey Kim on 5/13/25.
//

import Foundation



extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) //fixed timezone
        formatter.timeZone = .current
        return formatter
    }()
    

    
    static let monthTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }()
}

extension Date {
    // Date -> "yyyy-MM-dd"
    func toString() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
    
    func daysFromToday() -> Int {
        let calendar = Calendar.current
        //calculate only days
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: self)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
    
    func toMonthTitle() -> String {
        return DateFormatter.monthTitle.string(from: self)
    }
    
    func normalizedDate() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}

