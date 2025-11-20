//
//  ChoreCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI



struct ChoreCreateView: View {
    var onCreate: (() -> Void)? = nil
    var onUpdate: (() -> Void)? = nil
    var updateItem: ChoreItem? = nil
    
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChoreCreateViewModel()
    @State var selectedCycleType: CycleOption = .simple(.weekly)
    
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text((updateItem != nil) ? "집안일 수정하기" :"집안일 추가하기")
                    .font(.sheetTitle)
                Spacer()
            }
            .overlay(
                SaveButton(isEnabled: viewModel.isFormValid, action:{
                    if updateItem == nil {
                        viewModel.createChore()
                    }else {
                        viewModel.updateChore()
                    }
                    
                })
                .frame(maxWidth: .infinity, alignment: .trailing)
            )
            .padding(.top, 30)
            
            
            // Title
            UnderlineTextField(text: $viewModel.title, placeholder: "집안일")
                .padding(16)
            
            Divider()
            
            categoryPickerView
            
            Divider()
            
            cyclePickerView
            
            //Save button
            Spacer()
            
        }
        .onAppear {
            if let updateItem = updateItem {
                viewModel.setupForUpdate(updateItem)
            }
        }
        .onChange(of: updateItem) {
            if let updateItem = updateItem {
                viewModel.setupForUpdate(updateItem)
            }
        }
        .onChange(of: viewModel.cycleOption) {
            viewModel.clearSelectedOptions()
        }
        .onChange(of: viewModel.isChoreCreated) {
            if viewModel.isChoreCreated {
                onCreate?()
                dismiss()
            }
        }
        
        .withErrorToast()
    }
    
    private var categoryPickerView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing:24) {
                    ForEach(Constants.categoryOptions) { option in
                        CategoryRadioButton(option: option, isSelected: viewModel.category == option.value, onTap: {
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
                
                Toggle(isOn: $viewModel.isFixedCycle, label: { Text("고정 일정")})
                    .toggleStyle(SquareToggleStyle())
                    .onChange(of: viewModel.isFixedCycle) {
                        if viewModel.isFixedCycle {
                            viewModel.cycleOption = CycleOption.fixed(.day)
                        } else {
                            viewModel.cycleOption = CycleOption.simple(.weekly)
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
                    CycleOptionRadioButtons(title: option.display, isSelected: viewModel.cycleOption == .fixed(option), onTap: {
                        viewModel.cycleOption = .fixed(option)
                    })
                }
            } else {
                ForEach(SimpleCycleOption.allCases, id:\.self) { option in
                    CycleOptionRadioButtons(title: option.display, isSelected: viewModel.cycleOption == .simple(option), onTap: {
                        viewModel.cycleOption = .simple(option)
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
                                get: { viewModel.selectedDays.contains(day.serverData)},
                                set: { _ in
                                    if viewModel.selectedDays.contains(day.serverData) {
                                        viewModel.selectedDays.remove(day.serverData)
                                    } else {
                                        viewModel.selectedDays.insert(day.serverData)
                                    }
                                    print(viewModel.selectedDays)
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
                                get: { viewModel.selectedDates.contains(date.serverData)},
                                set: { _ in
                                    if viewModel.selectedDates.contains(date.serverData) {
                                        viewModel.selectedDates.remove(date.serverData)
                                    } else { viewModel.selectedDates.insert(date.serverData)}
                                    print(viewModel.selectedDates)
                                })
                        )
                    }
                }
                MultiSelectButton(
                    option: DateOptions.endOfMonth,
                    isSelected: Binding(
                        get: { viewModel.selectedDates.contains("END") },
                        set: { _ in
                            if viewModel.selectedDates.contains("END") {
                                viewModel.selectedDates.remove("END")
                            } else {
                                viewModel.selectedDates.insert("END")
                            }
                            print(viewModel.selectedDates)
                        }
                    )
                )
                
                
                
            case .fixed(.month):
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach(MonthOptions.allCases, id:\.self) { month in
                        MultiSelectButton(option: month, isSelected: Binding(
                            get: { viewModel.selectedMonths.contains(month.serverData) },
                            set: { _ in
                                if viewModel.selectedMonths.contains(month.serverData) {
                                    viewModel.selectedMonths.remove(month.serverData)
                                } else {
                                    viewModel.selectedMonths.insert(month.serverData)
                                }
                                print(viewModel.selectedMonths)
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
