//
//  ChoreCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI



struct ChoreCreateView: View {
    private enum FocusField {
        case title
    }
    
    var onSave: ((ChoreDraft) async -> Bool)? = nil
    var updateItem: ChoreItem? = nil
    @StateObject private var viewModel = ChoreCreateViewModel()
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss
    @State var selectedCycleType: CycleOption = .simple(.weekly)
    @FocusState private var focusedField: FocusField?
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            headerView
            
            // Title
            TextField("집안일", text: $viewModel.title)
                .textFieldStyle(.plain)
                .padding(16)
                .font(.listTitleMedium)
                .focused($focusedField, equals: .title)
            
            
            Divider()
            
            categoryPickerView
            
            Divider()
            
            cyclePickerView
            
        
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
            if let updateItem = updateItem {
                viewModel.setupForUpdate(updateItem)
                focusedField = nil
            }
        }
        
        .withErrorToast()
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text((updateItem != nil) ? "집안일 수정" :"새 집안일 추가")
                .font(.sheetTitle)
            Spacer()
        }
        .overlay(
            SaveButton(isEnabled: viewModel.isFormValid && !isSubmitting, action:{
                focusedField = nil
                save()
            },isEditMode: (updateItem != nil))
            .frame(maxWidth: .infinity, alignment: .trailing)
        )
        .padding(.top, 30)
        .padding(.bottom,10)
    }
    
    private var categoryPickerView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing:20) {
                    ForEach(Constants.categoryOptions) { option in
                        CategoryRadioButton(option: option, isSelected: viewModel.category == option.value, onTap: {
                            dismissTitleFocus()
                            viewModel.category = option.value
                        })
                        .id(option.value)
                    }
                }
            }
            .formLabel("어느 공간에 관련된 일인가요?")
            .padding(16)
            .onAppear {
                if let updateItem = updateItem {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(updateItem.roomCategory.lowercased(), anchor: .center)
                        }
                    }
                }
            }
        }
        
    }
    
    private var cyclePickerView: some View {
        VStack{
            //header
            HStack {
                Text("주기를 설정해주세요")
                    .font(.formlabel)
                Spacer()
                
                Toggle(
                    isOn: Binding(
                        get: { viewModel.isFixedCycle },
                        set: {
                            dismissTitleFocus()
                            viewModel.setIsFixedCycle($0)
                        }
                    ),
                    label: { Text("고정 일정") }
                )
                .toggleStyle(SquareToggleStyle())
            }
            // main option
            cycleTypeSection
                .padding(.top,16)
                .padding(.bottom, 10)
            
            //fixed - detail option
            if viewModel.isFixedCycle {
                fixedCycleDetailSection
            }
            
        }
        .padding(16)
    }
    
    private var cycleTypeSection: some View {
        HStack {
            if viewModel.isFixedCycle {
                ForEach(FixedCycleOption.allCases, id:\.self) { option in
                    CycleOptionRadioButtons(title: option.display, isSelected: viewModel.cycleOption == .fixed(option), onTap: {
                        dismissTitleFocus()
                        viewModel.setCycleOption(.fixed(option))
                    })
                }
            } else {
                ForEach(SimpleCycleOption.allCases, id:\.self) { option in
                    CycleOptionRadioButtons(title: option.display, isSelected: viewModel.cycleOption == .simple(option), onTap: {
                        dismissTitleFocus()
                        viewModel.setCycleOption(.simple(option))
                    })
                }
            }
        }
        
    }
    
    private var fixedCycleDetailSection: some View {
        VStack(alignment: .leading){
            
            switch viewModel.cycleOption {
            case .fixed(.day):
                HStack {
                    ForEach(DayOptions.allCases, id: \.self) { day in
                        MultiSelectButton(
                            option: day,
                            isSelected: Binding(
                                get: { viewModel.isDaySelected(day) },
                                set: { _ in
                                    dismissTitleFocus()
                                    viewModel.toggleDay(day)
                                }
                            )
                        )
                        .frame(maxWidth: .infinity)
                        
                    }
                }
                
            case .fixed(.date):
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach(DateOptions.allCases.filter { $0 != .endOfMonth }, id: \.self) { date in
                        MultiSelectButton(
                            option: date,
                            isSelected: Binding(
                                get: { viewModel.isDateSelected(date) },
                                set: { _ in
                                    dismissTitleFocus()
                                    viewModel.toggleDate(date)
                                })
                        )
                    }
                }
                MultiSelectButton(
                    option: DateOptions.endOfMonth,
                    isSelected: Binding(
                        get: { viewModel.isDateSelected(.endOfMonth) },
                        set: { _ in
                            dismissTitleFocus()
                            viewModel.toggleDate(.endOfMonth)
                        }
                    )
                )
                
                
                
            case .fixed(.month):
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach(MonthOptions.allCases, id:\.self) { month in
                        MultiSelectButton(option: month, isSelected: Binding(
                            get: { viewModel.isMonthSelected(month) },
                            set: { _ in
                                dismissTitleFocus()
                                viewModel.toggleMonth(month)
                            })
                        )
                    }
                }
            default: HStack{ }
                
            }
        }
        
    }
    
    private func dismissWithKeyboardCleanup() {
        focusedField = nil
        DispatchQueue.main.async {
            dismiss()
        }
    }
    
    private func save() {
        guard !isSubmitting else { return }
        guard let draft = viewModel.currentDraft else { return }
        
        focusedField = nil
        isSubmitting = true
        
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

    private func dismissTitleFocus() {
        focusedField = nil
    }
}

#Preview {
    ChoreCreateView()
}
