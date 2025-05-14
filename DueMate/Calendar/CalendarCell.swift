//
//  CalendarCell.swift
//  DueMate
//
//  Created by Kacey Kim on 5/13/25.
//

import SwiftUI

struct CalendarCell: Identifiable {
    let id = UUID()
    let date: Date
    let day: Int
    let isInCurrentMonth: Bool
    let isInHistory: Bool
    let isNextDue: Bool
    let isSelected: Bool
    
    func getBackgroundColor() -> Color {
        if isSelected {
            return Color.black
        } else if isInHistory {
            return CalendarColor.history
        } else if isNextDue {
            return CalendarColor.nextDue
        } else {
            return Color.white
        }
    }
    
    func getTextColor() -> Color {
        if !isInCurrentMonth {
            return .gray
        } else if isSelected || isNextDue || isInHistory {
            return .white
        } else {
            return .black
        }
    }
    
}


struct CalendarCellView: View {
    let theCell: CalendarCell
    // today: cirecle / history: color / nextdue: different
    var body: some View {
        VStack {
            Text("\(theCell.day)")
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(theCell.getBackgroundColor().opacity(theCell.isInCurrentMonth ? 1.0 : 0.4))
                )
                .foregroundColor(theCell.getTextColor())
        }
        .frame(height: 50)
    }
}
