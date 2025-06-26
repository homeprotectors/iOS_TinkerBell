//
//  Color+Extension.swift
//  DueMate
//
//  Created by Kacey Kim on 5/5/25.
//

import SwiftUI

enum ListColor {
    static let background = Color("test")
    
    static let overdue = Color("Overdue")
    static let warning = Color("Warning")
    static let normal = Color("Normal")
    
    static let overdue2 = Color("Overdue2")
    static let warning2 = Color("Warning2")
    static let normal2 = Color("Normal2")
    
    static let overdueText = Color("OverdueText")
    static let warningText = Color("WarningText")
    static let normalText = Color("NormalText")
    
}

enum ListStatus {
    case overdue
    case warning
    case normal
    
    var gradient: LinearGradient {
        switch self {
        case .overdue:
            return LinearGradient(
                colors: [ListColor.overdue, ListColor.overdue2],
                startPoint: .top,
                endPoint: .bottom)
        case .warning:
            return LinearGradient(
                colors: [ListColor.warning, ListColor.warning2],
                startPoint: .top,
                endPoint: .bottom)
        case .normal:
            return LinearGradient(
                colors: [ListColor.normal, ListColor.normal],
                startPoint: .top,
                endPoint: .bottom)
        }
    }
}

enum CalendarColor {
    static let history = Color("History")
    static let oldHistory = Color("OldHistory")
    static let nextDue = Color("Warning")
}
