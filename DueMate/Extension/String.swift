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
            formatter.timeZone = .current
            return formatter
        }()
}
