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
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        formatter.maximum = 999999
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("새 재고")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Title
            UnderlineTextField(text: $viewModel.title, placeholder: "ex. 휴지")
                .formLabel("이름")
            
            
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
            .sheet(isPresented: $showUnitPicker) {
                StockUnitPickerView(
                    quantity: $viewModel.unitQuantityString,
                    unit: $viewModel.unit
                )
            }
            
            
            // Current Amount
            VStack(alignment: .leading, spacing: 6) {
                UnderlineTextField(text: $viewModel.currentQuantityString, placeholder: "수량", suffix: viewModel.unit)
                    .formLabel("현재 수량")
                Group {
                    if showExpectedText {
                        Text("현재 약 \(viewModel.expectedDaysLeft)일치가 남았어요!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                    }
                }.animation(.easeInOut(duration: 0.3), value: viewModel.currentQuantityString)
            }
            
            
            // Reminder Picker
            ReminderField(selectedReminder: $viewModel.selectedReminder)
                .formLabel("알람")
            
            
            // Submit Button
            Spacer()
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
            .onChange(of: viewModel.isStockCreated) {
                if viewModel.isStockCreated {
                    onComplete?()
                    dismiss()
                }
            }
        }
        .padding(30)
        .onChange(of: viewModel.currentQuantity) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showExpectedText = (viewModel.currentQuantity ?? 0) > 0
            }
        }
    }
    
    
    
}


#Preview {
    StockCreateView()
}
