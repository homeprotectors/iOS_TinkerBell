//
//  CalendarView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let histories: [ChoreHistory]
    let nextDue: String
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                Button(action: viewModel.goToPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                Text(viewModel.currentMonth.toMonthTitle())
                    .font(.headline)
                Button(action: viewModel.goToNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.weekdaySymbols.indices) { index in
                        Text(viewModel.weekdaySymbols[index])
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.cells) { cell in
                    CalendarCellView(
                        cell: cell,
                        isSelected: cell.date == selectedDate,
                        isNextDue: cell.date.toString() == nextDue,
                        history: histories.first { $0.doneDate == cell.date.toString() }
                    )
                    .onTapGesture {
                        guard cell.isSelectable else { return }
                        selectedDate = cell.date
                        viewModel.selectedDate = cell.date
                        viewModel.generateCalendar()
                    }
                }
            }
        }
        
    }
}

#Preview {
    @Previewable @State var selectedDate: Date? = nil
    CalendarView(viewModel: CalendarViewModel(), histories: [ChoreHistory(id: 1, doneDate: "2025-06-05", doneBy: 1)], nextDue: "2025-06-10", selectedDate: $selectedDate)
}
