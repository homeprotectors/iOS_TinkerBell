//
//  BillCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 8/1/25.
//

import SwiftUI

struct BillCreateView: View {
    var onComplete: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BillCreateViewModel()
    @State private var showReminderPicker = false
    
    var body: some View {
        ZStack {
            //ListColor.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("New Bill")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                
                // Title
                UnderlineTextField(text: $viewModel.title, placeholder: "지출 내역")
                    .formLabel("지출")
                
                // Amount
                Picker("Options", selection: $viewModel.isFixed) {
                    Text("고정 비용").tag(true)
                    Text("변동 비용").tag(false)
                }
                .pickerStyle(.segmented)
                .formLabel("금액")
                UnderlineTextField(text: $viewModel.amountString, placeholder: viewModel.isFixed ? "달마다 나가는 고정 비용을 적어주세요" : "평균 금액을 적어주세요", suffix: "원")
                
                // Due date
                HStack{
                    DatePicker("", selection: $viewModel.dueDate, displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                }
                .formLabel("납부일")
                
                
                
                // Reminder
                ReminderField(selectedReminder: $viewModel.selectedReminder)
                    .formLabel("알람")
                
                
                //Save button
                Spacer()
                SaveButton(isEnabled: viewModel.isFormValid, action:{
                    viewModel.createBill()
                })
            }
        }
        .padding(30)
        .sheet(isPresented: $showReminderPicker) {
            ReminderPickerView(alert: $viewModel.selectedReminder)
        }
        .withErrorToast()
    }
}

#Preview {
    BillCreateView()
}
