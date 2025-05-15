//
//  ChoreDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct ChoreDetailView: View {
    @StateObject private var viewModel = ChoreDetailViewModel()
    let item: ChoreListItem
    var historyDates: [String] = []
    var body: some View {
        VStack{
            Text("\(item.title)")
            CalendarView(history: $viewModel.historyDates)
        }
        .task {
            do {
                try await viewModel.fetchHistory(for: item.id)
                
            } catch {
                print("fetch canceled")
            }
            
        }
        
    }
        
}

#Preview {
    ChoreDetailView(item: ChoreListItem(id: 1, title: "빨래하기", cycleDays: 3, nextDue: "2025-05-13", reminderEnabled: true))
}
