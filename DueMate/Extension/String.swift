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
