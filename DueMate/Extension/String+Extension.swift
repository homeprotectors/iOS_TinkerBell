//
//  String+Extension.swift
//  DueMate
//
//  Created by Kacey Kim on 5/1/25.
//

import Foundation



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

extension Optional where Wrapped == Int {
    func getReminderOption() -> ReminderOptions {
        switch self {
        case .some(0): return .theDay
        case .some(1): return .oneDayBefore
        case .some(2): return .twoDaysBefore
        default: return .none
        }
    }
}
