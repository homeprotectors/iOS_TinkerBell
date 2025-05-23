//
//  StockCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/20/25.
//

import SwiftUI

struct StockCreateView: View {
    var onComplete: (() -> Void)? = nil
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StockCreateViewModel()
    
    @State private var showUnitPicker = false
    @State private var showReminderPicker = false
    @State private var showExpectedText = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("새 재고")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("물건 이름")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("ex. 휴지", text: $viewModel.title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
            }
            
            // Consumption rate
            VStack(alignment: .leading) {
                Text("소모 주기")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack(spacing: 12) {
                    TextField("n", value: $viewModel.usageDays, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    Text("일에")
                    Spacer()
                    HStack(spacing: 0) {
                        TextField("수량", value: $viewModel.consumptionDays, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .padding(.leading)
                            .background(Color.clear)
                        
                        Button {
                            showUnitPicker = true
                        } label: {
                            HStack {
                                Text(viewModel.consumptionUnit)
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            .frame(minWidth: 60)
                            
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
            }
            
            
            // Current Amount
            VStack(alignment: .leading, spacing: 6) {
                Text("현재 재고")
                    .font(.caption)
                    .foregroundColor(.gray)
                HStack {
                    TextField("수량", value: $viewModel.currentAmount, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    
                    Text(viewModel.consumptionUnit)
                        .foregroundColor(.gray)
                }
                Group {
                    if showExpectedText {
                        Text("현재 약 \(viewModel.expectedDaysLeft)일치가 남았어요!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                    }
                }.animation(.easeInOut(duration: 0.3), value: viewModel.currentAmount)
                
            }
            
            
            // Reminder Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Reminder")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showReminderPicker = true
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
                .sheet(isPresented: $showReminderPicker) {
                    AlertSheet(alert: $viewModel.selectedReminder)
                }
            }
            Spacer()
            // Submit Button
            Button {
                viewModel.createStock()
            } label: {
                Text("저장")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? Color.black : Color.gray.opacity(0.4))
                    .foregroundColor(viewModel.isFormValid ? .white : .gray)
                    .cornerRadius(16)
            }
            .disabled(!viewModel.isFormValid)
            .padding(.top, 12)
            .onChange(of: viewModel.isStockCreated) {
                if viewModel.isStockCreated {
                    onComplete?()
                    dismiss()
                }
            }
            
        }
        .padding(25)
        .onChange(of: viewModel.currentAmount) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showExpectedText = (viewModel.currentAmount ?? 0) > 0
            }
        }
    }
    
    
    
}


#Preview {
    StockCreateView()
}
