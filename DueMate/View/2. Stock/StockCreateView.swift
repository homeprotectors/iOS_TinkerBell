//
//  StockCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/20/25.
//

import SwiftUI

struct StockCreateView: View {
    var onCreate: ((StockItem) -> Void)? = nil
    var onUpdate: ((StockItem) -> Void)? = nil
    var updateItem: StockItem? = nil
    var isEditMode: Bool { updateItem != nil }
        
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StockCreateViewModel()
    @State private var showExpectedText = false
    @State private var showUnsavedChangesAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            headerView
            
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
            if !isEditMode {
                VStack(alignment: .leading, spacing: 6) {
                    UnderlineTextField(text: $viewModel.currentQuantityString, placeholder: "수량", suffix: viewModel.unit)
                        .formLabel("현재 몇 개가 남아있나요?")
                    // estimated days
                    Group {
                        if showExpectedText {
                            Text("현재 약 \(viewModel.expectedDaysLeft)일치가 남았어요!")
                                .font(.listText)
                                .foregroundColor(.secondary)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Divider()
                    .padding(.vertical, 12)
            }
            Spacer()
        }
        .padding(.top, 30)
        .onAppear {
            if let updateItem = updateItem {
                viewModel.setupForUpdate(updateItem)
            }
        }
        .onChange(of: updateItem) {
            viewModel.setupForUpdate(updateItem!)
        }
        .onChange(of: viewModel.currentQuantity) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showExpectedText = (viewModel.currentQuantity) > 0
            }
        }
        .onChange(of: viewModel.isStockCreated) {
            if viewModel.isStockCreated {
                let newStock = StockItem(
                    id: -Int.random(in: 1000...9999),
                    name: viewModel.title,
                    unitDays: viewModel.unitDays,
                    unitQuantity: viewModel.unitQuantity,
                    currentQuantity: viewModel.currentQuantity,
                    remainingDays: viewModel.expectedDaysLeft)
                onCreate?(newStock)
                dismiss()
            }
        }
        
    }
    
    private var headerView: some View {
        HStack {
            Text(isEditMode ? "물품 수정하기" : "물품 추가하기")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .overlay(
            SaveButton(isEnabled: viewModel.isFormValid, action:{
                viewModel.isStockCreated = true
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
        )
        .padding(.bottom, 24)
        
    }
    
}


#Preview {
    StockCreateView()
}
