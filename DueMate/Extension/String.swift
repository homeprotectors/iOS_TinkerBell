//
//  String+Extension.swift
//  DueMate
//
//  Created by Kacey Kim on 5/1/25.
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
}


extension String {
    // "yyyy-MM-dd" -> Date
    func toDate() -> Date? {
        return DateFormatter.yyyyMMdd.date(from: self)
    }
    
    func daysFromToday() -> Int? {
        guard let date = self.toDate() else { return nil }
        return date.daysFromToday()
    }
}
