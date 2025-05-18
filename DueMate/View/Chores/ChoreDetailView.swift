//
//  ChoreDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct ChoreDetailView: View {
    var item: ChoreItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainViewModel: ChoreMainViewModel
    @StateObject private var viewModel =  ChoreDetailViewModel()
    
    @State private var showPicker = false
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    
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
                            Text(viewModel.reminderOption.rawValue)
                                .foregroundColor(viewModel.reminderOption == .none ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showPicker) {
                        AlertSheet(alert: $viewModel.reminderOption)
                    }
                }
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.updateChore(for: item.id)
                            mainViewModel.shouldRefresh = true
                            dismiss()
                        } catch {
                            print("Failed to save chore: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.hasInputChanges() ? Color.blue : .gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(!viewModel.hasInputChanges())
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if viewModel.hasInputChanges() {
                        showCancelAlert = true
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
        .alert("변경 내용을 취소하시겠습니까?", isPresented: $showCancelAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("저장하지 않은 변경 사항이 사라집니다.")
        }
        .onAppear{
            var reminder: alertOptions
            if !item.reminderEnabled {
                reminder = .none
            }else{
                reminder = item.reminderDays.getReminderOption()
            }
            
            viewModel.firstInputSetting(title: item.title, cycleDays: String(item.cycleDays) , reminderOption: reminder)
            
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
    ChoreDetailView(item: ChoreItem(id: 1, title: "빨래하기", cycleDays: 3, nextDue: "2025-05-13", reminderEnabled: true, reminderDays: 1))
}
