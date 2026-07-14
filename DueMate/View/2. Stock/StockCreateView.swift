//
//  StockCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/20/25.
//

import SwiftUI

struct StockCreateView: View {
    private enum FocusField {
        case title
    }
    
    var onSave: ((StockDraft) async -> Bool)? = nil
    var updateItem: StockItem? = nil
    var isEditMode: Bool { updateItem != nil }

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StockCreateViewModel()
    @State private var showExpectedText = false
    @State private var isSubmitting = false
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        VStack(spacing: 0) {
            
            headerView
            
            // Title
            TextField("물품", text: $viewModel.title)
                .textFieldStyle(.plain)
                .font(.listTitleMedium)
                .padding(16)
                .focused($focusedField, equals: .title)

            Divider()
                
            
                
            
            // Consumption rate
            HStack {
                UnderlineTextField(text: $viewModel.unitDaysString, placeholder: "주기 (1 - 365)", keyboardType: .numberPad)
                Text("일에")
                    .font(.listTitleMedium)
                    .padding(.trailing,20)
                UnderlineTextField(text: $viewModel.unitQuantityString, placeholder: "수량", keyboardType: .numberPad, suffix: "개")
                
            }
            .formLabel("얼마나 자주 쓰나요?")
            .padding(16)
            
            Divider()
                
            
            
            // Current Amount
            if !isEditMode {
                VStack(alignment: .leading, spacing: 6) {
                    UnderlineTextField(text: $viewModel.currentQuantityString, placeholder: "수량",keyboardType: .numberPad, suffix: viewModel.unit)
                        .formLabel("현재 몇 개가 남아있나요?")
                    // estimated days
                    Group {
                        if showExpectedText {
                            Text("현재 약 \(viewModel.expectedDaysLeft)일치가 남았어요!")
                                .font(.listText)
                                .foregroundColor(.accentColor)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding(16)
                
                Divider()
                    
            }
            Spacer()
        }
        .onAppear {
            if let updateItem = updateItem {
                viewModel.setupForUpdate(updateItem)
                focusedField = nil
            } else {
                DispatchQueue.main.async {
                    focusedField = .title
                }
            }
        }
        .onChange(of: updateItem) {
            guard let updateItem else { return }
            viewModel.setupForUpdate(updateItem)
            focusedField = nil
        }
        .onChange(of: viewModel.currentQuantity) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showExpectedText = (viewModel.currentQuantity) > 0
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text((updateItem != nil) ? "물품 수정" :"새 물품 추가")
                .font(.sheetTitle)
            Spacer()
        }
        .overlay(
            SaveButton(isEnabled: viewModel.isFormValid && !isSubmitting, action:{
                save()
            },isEditMode: isEditMode)
            .frame(maxWidth: .infinity, alignment: .trailing)
        )
        .padding(.top, 30)
        .padding(.bottom, 24)
        
    }
    
    private func dismissWithKeyboardCleanup() {
        focusedField = nil
        DispatchQueue.main.async {
            dismiss()
        }
    }

    private func save() {
        guard !isSubmitting else { return }
        focusedField = nil
        isSubmitting = true
        
        let draft = StockDraft(
            name: viewModel.title,
            unitDays: viewModel.unitDays,
            unitQuantity: viewModel.unitQuantity,
            currentQuantity: viewModel.currentQuantity
        )
        
        Task {
            let didSave = await onSave?(draft) ?? false
            
            await MainActor.run {
                if didSave {
                    dismissWithKeyboardCleanup()
                } else {
                    isSubmitting = false
                }
            }
        }
    }
    
}


#Preview {
    StockCreateView()
}
