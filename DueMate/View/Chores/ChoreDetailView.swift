//
//  ChoreDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct ChoreDetailView: View {
    @EnvironmentObject var mainViewModel: ChoreMainViewModel
    @StateObject private var viewModel = ChoreDetailViewModel()
    var item: ChoreItem
    
    var body: some View {
        ScrollView{
            
            VStack(spacing: 15){
                HStack(spacing: 8) {
                    TextField("", text: $viewModel.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .textFieldStyle(.plain)
                        .fixedSize()
                    Image(systemName: "pencil")
                        .font(.system(size: 30))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding([.top,.horizontal],30)
                
                
                CalendarView(history: $viewModel.historyDates)
                
                VStack(alignment: .leading) {
                    Text("Cycle (days)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    TextField("\(item.cycleDays)", text: $viewModel.cycleDays)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.updateChore(for: item.id)
                            mainViewModel.shouldRefresh = true
                        } catch {
                            print("Failed to save chore: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteChore(for: item.id)
                            mainViewModel.shouldRefresh = true
                        } catch {
                            print("Failed to delete chore: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("Delete Chore")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
            }
        }
        .padding()
        .onAppear{
            viewModel.title = item.title
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
    ChoreDetailView(item: ChoreItem(id: 1, title: "빨래하기", cycleDays: 3, nextDue: "2025-05-13", reminderEnabled: true))
}
