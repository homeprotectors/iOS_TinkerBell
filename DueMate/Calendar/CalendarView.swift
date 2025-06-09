//
//  CalendarView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var history: [ChoreHistory]
    @StateObject private var viewModel = CalendarViewModel()
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack {
            
            // MARK: - month title bar
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    viewModel.goToPreviousMonth()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.black)
                })
                //.disabled()
                
                Text(viewModel.currentMonth.toMonthTitle())
                    .font(.headline)
                
                Button(action: {
                    viewModel.goToNextMonth()
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(.black)
                })
                .disabled(!viewModel.isNextMonthAvaliable)
                
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.weekdaySymbols.indices) { index in
                    Text(viewModel.weekdaySymbols[index])
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            
            // MARK: - calendar grid view
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.cells) { cell in
                    CalendarCellView(theCell: cell)
                        .onTapGesture {
                            guard cell.isSelectable else { return }
                            selectedDate = cell.date
                            viewModel.selectedDate = cell.date
                            viewModel.generateCalendar()
                        }
                }
            }
            
        }
        .padding()
        .onChange(of: history) {
            viewModel.loadHistory(history)
        }
        .onAppear {
            viewModel.loadHistory(history)
        }
        
    }
    
}




#Preview {
    @Previewable @State var selectedDate: Date? = nil
    CalendarView(history: .constant([ChoreHistory(id: 1, doneDate: "2025-06-05", doneBy: 1)]), selectedDate: $selectedDate)
}
