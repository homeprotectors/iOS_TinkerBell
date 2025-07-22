//
//  StockDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 7/4/25.
//

import SwiftUI

struct StockDetailView: View {
    let item: StockItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainViewModel: StockMainViewModel
    @StateObject private var viewModel = StockDetailViewModel()
    
    @State private var showReminderPicker = false
    @State private var showUnitPicker = false
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    @State private var showQuantityOverlay = false
    
    @State private var tempQuantity: String = ""
    @Namespace private var animation
    
    
    var body: some View {
        ZStack {
            // background color
//            ListColor.background
//                .ignoresSafeArea()
            
            VStack(spacing: 30){
                //title
                TitleTextField(title: $viewModel.title)
                
                //current quantity view
                CurrentQuantityView(quantity: viewModel.currentQuantity, color: .overdue, onTap: {
                    tempQuantity = viewModel.currentQuantity
                    withAnimation(.spring()) {
                        showQuantityOverlay = true
                    }
                })
                
                // Consumption rate
                HStack {
                    UnderlineTextField(text: $viewModel.unitDaysString,keyboardType: .numberPad)
                    Text("일에")
                        .padding(.trailing,20)
                    UnderlineTextField(text: $viewModel.unitQuantityString, keyboardType: .numberPad)
                    Button {
                        showUnitPicker = true
                    } label: {
                        HStack {
                            Text(viewModel.unit)
                                .font(.system(size: 18))
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                                
                        }
                        .foregroundColor(.primary)
                    }
                }
                .formLabel("소모 주기")
                .padding(.top, 20)
                .sheet(isPresented: $showUnitPicker) {
                    StockUnitPickerView(
                        quantity: $viewModel.unitQuantityString,
                        unit: $viewModel.unit
                    )
                }
                
                //reminder
                ReminderField(selectedReminder: $viewModel.reminderOptions)
                    .formLabel("알람")
                
                
                // Save Button
                Spacer()
                Button(action: {
                    //update
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.hasInputChanged() ? Color.blue : .gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(!viewModel.hasInputChanged())
                .onChange(of: viewModel.shoudRedirectMain) {
                    if viewModel.shoudRedirectMain {
                        mainViewModel.shouldRefresh = true
                        dismiss()
                    }
                }
                
                
                // Delete Button
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Chore")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .alert("이 할 일을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                    Button("삭제", role: .destructive){
                       //삭제
                    }
                    Button("취소",role: .cancel) {}
                }
            }
            .onAppear{
                viewModel.firstInputSetting(item: item)
            }
            
            if showQuantityOverlay {
                QuantityOverlayView(isPresented: $showQuantityOverlay, quantity: $tempQuantity , color: .overdue, onSave: { print("저장 \(tempQuantity)")})
            }
            
        }
        .padding(30)
    }
    
   
}

#Preview {
    StockDetailView(item: StockItem(id: 1, title: "휴지", unitDays: 3, unitQuantity: 1, unit: "개", nextDue: "2025-07-29", reminderDays: 1))
}
