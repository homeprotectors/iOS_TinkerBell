//
//  ChoreDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct ChoreDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainViewModel: ChoreMainViewModel
    @StateObject private var viewModel = ChoreDetailViewModel()
    @State private var showDeleteAlert = false
    @State private var showPicker = false
    var item: ChoreItem
    
    var body: some View {
        ScrollView{
            //title
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
                .padding(20)
                
                //history calendar
                CalendarView(history: $viewModel.historyDates)
                
                // cycle days
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cycle")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("", text: $viewModel.cycleDays)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        Text("일")
                            .foregroundColor(.gray)
                    }
                }
                
                
                //alert
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reminder")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showPicker = true
                    }) {
                        HStack {
                            Text(viewModel.selectedAlert.rawValue)
                                .foregroundColor(viewModel.selectedAlert == .none ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showPicker) {
                        AlertSheet(alert: $viewModel.selectedAlert)
                    }
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
                    showDeleteAlert = true
                    
                } label: {
                    Text("Delete Chore")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .alert("이 할 일을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                    Button("삭제", role: .destructive){
                        Task {
                            do {
                                try await viewModel.deleteChore(id: item.id)
                                mainViewModel.shouldRefresh = true
                                dismiss()
                            } catch {
                                print("Failed to delete chore: \(error.localizedDescription)")
                            }
                        }
                    }
                    Button("취소",role: .cancel) {}
                }
                
            }
        }
        .padding()
        .onAppear{
            viewModel.title = item.title
            viewModel.cycleDays = String(item.cycleDays)
            if item.reminderEnabled {
                viewModel.selectedAlert = .theDay
            }else {
                viewModel.selectedAlert = .none
            }
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
