//
//  CalendarView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date?
    
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
                            viewModel.selectedDate = cell.date
                            viewModel.generateCalendar()
                        }
                }
            }
            
        }
        .padding()
        .onAppear {
            viewModel.loadHistory([
                // 여기에 서버에서 받은 날짜 리스트 넣기
                "2025-03-19", "2025-04-03", "2025-05-11","2025-05-13"
            ])
        }
    }
    
}




#Preview {
    CalendarView()
}
