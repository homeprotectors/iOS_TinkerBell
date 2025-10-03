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
    @State var selectedCycleType: CycleOption = .simple(.weekly)
    @State var isWheelPresented = false
    @State var customDate = 1
    
    var body: some View {
        
        VStack(spacing: 0) {
            Text("집안일 추가하기")
                .font(.sheetTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            // Title
            UnderlineTextField(text: $viewModel.title, placeholder: "집안일")
                .padding(16)
            
            Divider()
            
            categoryPickerView
            
            Divider()
            
            cyclePickerView
            
            //Save button
            Spacer()
            SaveButton(isEnabled: viewModel.isFormValid, action:{
                viewModel.createChore()
            })
        }
        
        .onChange(of: selectedCycleType) {
            viewModel.clearSelectedOptions()
        }
        .onChange(of: viewModel.isChoreCreated) {
            if viewModel.isChoreCreated {
                onComplete?()
                dismiss()
            }
        }
        
        .withErrorToast()
    }
    
    private var categoryPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing:24) {
                ForEach(Constants.categoryOptions) { option in
                    CategoryRadioButton(option: option, isSelected: viewModel.category == option.value, onTap: {
                        viewModel.category = option.value
                        
                    })
                }
            }
        }
        .formLabel("어느 공간에 관련된 일인가요?")
        .padding(16)
    }
    
    private var cyclePickerView: some View {
        VStack{
            //header
            HStack {
                Text("주기를 설정해주세요")
                    .font(.formlabel)
                Spacer()
                
                Toggle(isOn: $viewModel.isFixedCycle, label: { Text("고정 일정")})
                    .toggleStyle(squareToggleStyle())
                    .onChange(of: viewModel.isFixedCycle) {
                        if viewModel.isFixedCycle {
                            selectedCycleType = CycleOption.fixed(.day)
                        } else {
                            selectedCycleType = CycleOption.simple(.weekly)
                        }
                    }
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
                    CycleOptionRadioButtons(title: option.display, isSelected: selectedCycleType == .fixed(option), onTap: {
                        selectedCycleType = .fixed(option)
                    })
                }
            } else {
                ForEach(SimpleCycleOption.allCases, id:\.self) { option in
                    CycleOptionRadioButtons(title: option.display, isSelected: selectedCycleType == .simple(option), onTap: {
                        selectedCycleType = .simple(option)
                    })
                }
            }
        }
        
    }
    
    private var fixedCycleDetailSection: some View {
        VStack(alignment: .leading){
            
            switch selectedCycleType {
            case .fixed(.day):
                HStack {
                    ForEach(DayOptions.allCases, id: \.self) { day in
                        MultiSelectButton(
                            option: day,
                            isSelected: Binding(
                                get: { viewModel.selectedDays.contains(day)},
                                set: { _ in
                                    if viewModel.selectedDays.contains(day) {
                                        viewModel.selectedDays.remove(day)
                                    } else {
                                        viewModel.selectedDays.insert(day)
                                    }
                                }
                            )
                        )
                        .frame(maxWidth: .infinity)
                        
                    }
                }
                
            case .fixed(.date):
                HStack {
                    ForEach(DateOptions.allCases, id: \.self) { date in
                        MultiSelectButton(
                            option: date,
                            onTap: {
                                if date == .custom {
                                    isWheelPresented = true
                                }
                            }, isSelected: Binding(
                                get: { viewModel.selectedDates.contains(date) },
                                set: { _ in
                                    if viewModel.selectedDates.contains(date) {
                                        viewModel.selectedDates.remove(date)
                                    } else {
                                        viewModel.selectedDates.insert(date)
                                    }
                                })
                        )
                    }
                }
                .sheet(isPresented: $isWheelPresented) {
                    Picker("", selection: $customDate) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)일").tag(day)
                        }
                    }
                    .pickerStyle(.wheel)   // 휠 스타일
                    .frame(height: 300)
                    .presentationDetents([.fraction(0.4)])
                }
                
            case .fixed(.month):
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach(MonthOptions.allCases, id:\.self) { month in
                        MultiSelectButton(option: month, isSelected: Binding(
                            get: { viewModel.selectedMonths.contains(month) },
                            set: { _ in
                                if viewModel.selectedMonths.contains(month) {
                                    viewModel.selectedMonths.remove(month)
                                } else {
                                    viewModel.selectedMonths.insert(month)
                                }
                            })
                        )
                    }
                }
            default: HStack{ }
                
            }
        }
        
    }
}

#Preview {
    ChoreCreateView()
}
