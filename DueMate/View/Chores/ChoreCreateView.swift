//
//  ChoreCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI



struct ChoreCreateView: View {
    var onComplete: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChoreCreateViewModel()
    @State private var showReminderPicker = false
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        formatter.maximum = 365
        return formatter
    }()
    
    
    
    var body: some View {
        ZStack {
            //ListColor.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("New Chore")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                
                // Title
                UnderlineTextField(text: $viewModel.title, placeholder: "Title")
                    .formLabel("할 일")
                
                
                // Cycle
                HStack {
                    UnderlineTextField(text: $viewModel.cycle, placeholder: "1 - 365", suffix: "일에 한 번")
                    
                }
                .formLabel("주기")
                
                
                // Start Day
                HStack{
                    DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                }
                .formLabel("시작일")
                
                
                // Reminder
                ReminderField(selectedReminder: $viewModel.selectedReminder)
                    .formLabel("알람")
                
                
                Spacer()
                // Submit Button
                Button {
                    viewModel.createChore()
                } label: {
                    Text("생성")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .disabled(!viewModel.isFormValid)
                
                
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
    ChoreCreateView()
}
