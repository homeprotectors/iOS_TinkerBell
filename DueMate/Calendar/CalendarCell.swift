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
    let isSelectable: Bool
}

struct CalendarCellView: View {
    let cell: CalendarCell
    let isSelected: Bool
    let isNextDue: Bool
    let history: ChoreHistory?

    var body: some View {
        VStack {
            Text("\(cell.day)")
                .fontWeight(cell.isSelectable ? .bold : .regular)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(getBackgroundColor().opacity(cell.isInCurrentMonth ? 1.0 : 0.4))
                )
                .foregroundColor(getTextColor())
        }
        .frame(width: 40, height: 40)
    }

    private func getBackgroundColor() -> Color {
        if isSelected { return .black }
        if let history = history {
            let opacity = cell.isSelectable ? 0.7 : 0.3
            switch history.doneBy {
            case 1: return .blue.opacity(opacity)
            case 2: return .green.opacity(opacity)
            case 3: return .purple.opacity(opacity)
            default: return cell.isSelectable ? CalendarColor.history : CalendarColor.oldHistory
            }
        }
        if isNextDue { return CalendarColor.nextDue }
        return .white
    }

    private func getTextColor() -> Color {
        if !cell.isSelectable {
            return history != nil ? .white : .gray
        }
        if !cell.isInCurrentMonth { return .gray }
        if isSelected || isNextDue || history != nil { return .white }
        return .black
    }
}
