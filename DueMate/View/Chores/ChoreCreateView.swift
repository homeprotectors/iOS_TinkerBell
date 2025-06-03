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
    @State private var showPicker = false
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        formatter.maximum = 365
        return formatter
    }()
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Text("New Chore")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("New Chore Title", text: $viewModel.title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            // Cycle Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Cycle")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("1-365", text: $viewModel.cycle)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.cycle) {
                            
                            let filtered = viewModel.cycle.filter { $0.isNumber }
                            if filtered != viewModel.cycle {
                                viewModel.cycle = filtered
                            }
                            
                            
                            if let number = Int(filtered) {
                                if number < 1 || number > 365 {
                                    viewModel.cycle = ""
                                    Task { @MainActor in
                                        ErrorHandler.shared.handle(ValidationError.outOfRange365)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Text("일에 한 번")
                        .foregroundColor(.gray)
                }
            }
            
            //Start Day
            HStack(spacing: 8) {
                Text("Start Day")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                
                Text("\(DateFormatter.yyyyMMdd.string(from: viewModel.startDate))")
                
                DatePicker("",selection: $viewModel.startDate, displayedComponents: .date)
                    .labelsHidden()
                    .padding()
                    
                    
            }
            
            // Alert Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Reminder")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showPicker = true
                }) {
                    HStack {
                        Text(viewModel.selectedReminder.rawValue)
                            .foregroundColor(viewModel.selectedReminder == .none ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showPicker) {
                    ReminderPickerView(alert: $viewModel.selectedReminder)
                }
            }
            
            // Submit Button
            Button(action: {
                viewModel.createChore()
            }) {
                Text("생성")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? Color.black : Color.gray.opacity(0.4))
                    .foregroundColor(viewModel.isFormValid ? .white : .gray)
                    .cornerRadius(16)
            }
            .disabled(!viewModel.isFormValid)
            .padding(.top, 12)
            .onChange(of:viewModel.isChoreCreated){
                if viewModel.isChoreCreated {
                    onComplete?()
                    dismiss()
                }
            }
            
            Spacer()
        }
        .toolbar(.hidden, for: .tabBar)
        .padding(24)
        .background(Color(.systemBackground))
        .withErrorToast()
    }
    
}

#Preview {
    ChoreCreateView()
}
