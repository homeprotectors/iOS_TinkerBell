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
        VStack(alignment: .leading) {
            Text("물품 추가하기")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 28)
            
            // Title
            UnderlineTextField(text: $viewModel.title, placeholder: "ex. 휴지")
                .formLabel("이름")
                .padding(.horizontal, 16)
                
            Divider()
                .padding(.vertical, 12)
            
                
            
            // Consumption rate
            HStack {
                UnderlineTextField(text: $viewModel.unitDaysString, placeholder: "주기 (1 - 365)", keyboardType: .numberPad)
                Text("일에")
                    .padding(.trailing,20)
                UnderlineTextField(text: $viewModel.unitQuantityString, placeholder: "수량", keyboardType: .numberPad, suffix: "개")
                
            }
            .formLabel("얼마나 자주 쓰나요?")
            .padding(.horizontal, 16)
            
            Divider()
                .padding(.vertical, 12)
            
            
            // Current Amount
            VStack(alignment: .leading, spacing: 6) {
                UnderlineTextField(text: $viewModel.currentQuantityString, placeholder: "수량", suffix: viewModel.unit)
                    .formLabel("현재 수량")
                // estimated days
                Group {
                    if showExpectedText {
                        Text("현재 약 \(viewModel.expectedDaysLeft)일치가 남았어요!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                    }
                }.animation(.easeInOut(duration: 0.3), value: viewModel.currentQuantityString)
            }
            .padding(.horizontal, 16)
            
            Divider()
                .padding(.vertical, 12)
            
            
            Spacer()
            // Save button
            SaveButton(isEnabled: viewModel.isFormValid, action:{
                viewModel.createStock()
            })
            .padding(12)
        }
        .padding(.top, 20)
        .onChange(of: viewModel.currentQuantity) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showExpectedText = (viewModel.currentQuantity ?? 0) > 0
            }
        }
        .onChange(of: viewModel.isStockCreated) {
            if viewModel.isStockCreated {
                onComplete?()
                dismiss()
            }
        }
    }
    
    
    
}


#Preview {
    StockCreateView()
}
