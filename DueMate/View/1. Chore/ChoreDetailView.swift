//
//  ChoreDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct ChoreDetailView: View {
    let item: ChoreItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainViewModel: ChoreMainViewModel
    @StateObject private var viewModel = ChoreDetailViewModel()
    
    @State private var selectedDate: Date? = nil
    @State private var showDialog = false
    @State private var showReminderPicker = false
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 30){
                //title
                TitleTextField(title: $viewModel.title)
                
                //history calendar
                CalendarView(
                    viewModel: CalendarViewModel(),
                    histories: viewModel.histories,
                    nextDue: item.nextDue,
                    selectedDate: $selectedDate
                )
                
                // cycle days
                UnderlineTextField(text: $viewModel.cycleDays,keyboardType: .numberPad, suffix: "일")
                    .formLabel("주기")
                    .padding(.top,20)
                
                
                // alert
                ReminderField(selectedReminder: $viewModel.reminderOption)
                    .formLabel("알람")
                
                
                Spacer()
                // action buttons
                HStack {
                    // Delete Button
                    DeleteButton(showAlert: $showDeleteAlert, action: {
                        viewModel.deleteChore(id: item.id)
                    })
                    
                    //save button
                    SaveButton(isEnabled: viewModel.hasInputChanged(), action:{
                        viewModel.updateChore(for: item.id)
                    })
                }
                
            }
            
            
            if showDialog {
                if let selectedDate = selectedDate {
                    if viewModel.isInHistory(selectedDate) {
                        ConfirmationDialog(
                            isPresented: $showDialog,
                            type: .historyCancelation,
                            onConfirm: {
                                viewModel.editHistory(complete: false, id:item.id, date: selectedDate.toString())
                                print("date: \(selectedDate.toString())")
                            }
                        )
                    } else {
                        ConfirmationDialog(
                            isPresented: $showDialog,
                            type: .historyCompletion,
                            onConfirm: {
                                viewModel.editHistory(complete: true, id:item.id, date: selectedDate.toString())
                            }
                        )
                    }
                }
            }
        }
        .padding(30)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if viewModel.hasInputChanged() {
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
//            viewModel.firstInputSetting(title: item.title, cycleDays: String(item.cycleDays) , reminderOption: item.reminderDays.getReminderOption())
        }
        .onChange(of: selectedDate) {
            if selectedDate != nil {
                showDialog = true
            }
        }
        .onChange(of: viewModel.isHistoryUpdated) {
            if viewModel.isHistoryUpdated {
                mainViewModel.shouldRefresh = true
            }
        }
        .onChange(of: viewModel.shoudRedirectMain) {
            if viewModel.shoudRedirectMain {
                mainViewModel.shouldRefresh = true
                dismiss()
            }
        }
        .task {
            do {
                viewModel.fetchHistory(for: item.id)
            } catch {
                print("fetch canceled")
            }
        }
    }
    
    
}

#Preview {
   
}
