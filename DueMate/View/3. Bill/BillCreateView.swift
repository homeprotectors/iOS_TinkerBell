//
//  BillCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 8/1/25.
//

import SwiftUI

struct BillCreateView: View {
    var onCreate: (() -> Void)? = nil
    var onUpdate: (() -> Void)? = nil
    var updateItem: BillItem? = nil
    var isEditMode: Bool {
        updateItem != nil
    }
    
    @StateObject private var viewModel = BillCreateViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showDatePicker = false
    
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                headerView
                
                // Title
                UnderlineTextField(text: $viewModel.title, placeholder: "지출 내역")
                //                .formLabel("이름")
                    .padding(16)
                Divider()
                
                // Amount
                
                amountView
                Divider()
                
                
                // Due date
                dueDateView
                Divider()
                
                
                Spacer()
                
            }
            if showDatePicker {
                Color.black.opacity(0.05)
                    .blur(radius: 50)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showDatePicker = false
                        }
                    }
            }
            // picker sheet
            datePickerView
        }
        .onAppear{
            if let item = updateItem {
                viewModel.setUp(item: item)
            }
        }
        .withErrorToast()
        
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text(isEditMode ? "고정 지출 수정하기" : "고정 지출 추가하기")
                .font(.listTitle)
            Spacer()
        }
        .overlay(
            SaveButton(isEnabled: viewModel.isFormValid, action: {
                if updateItem == nil {
                    //viewModel.createBill()
                } else {
                    //viewModel.updateBill()
                }
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
        )
        .padding(.top, 30)
        .padding(.bottom, 24)
    }
    
    private var amountView: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text(viewModel.isVariable ? "매달 달라지는 지출은 목록에서 직접 입력할 수 있어요" :  "매달 결제되는 금액을 적어주세요")
                    .font(.listText)
                Spacer()
                Toggle(isOn: $viewModel.isVariable, label: {Text("고정 일정")})
                    .toggleStyle(CustomLabelToggleStyle())
                
            }
            
            if !viewModel.isVariable {
                HStack {
                    Image("ic_krw")
//                    UnderlineTextField(text: $viewModel.amountString, placeholder: "10,000", suffix: "원")
                    TextField("10,000", value: $viewModel.amount, format: .number.grouping(.automatic))
                    Text("원")
                }
                .padding(.top, 10)
            }
            
        }
        .padding(18)
    }
    
    private var dueDateView: some View {
        HStack {
            Image("ic_calendar")
            Button {
                showDatePicker = true
            } label: {
                HStack {
                    Text(viewModel.dueDate == 0 ? "납부일" : "\(viewModel.dueDate) 일")
                        .foregroundColor(viewModel.dueDate == 0 ? .gray : Color.primaryText)
                    Spacer()
                    Image("arrow_double")
                }
            }
        }
        .padding(18)
       
    }
    
    private var datePickerView: some View {
        
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Spacer()
                    Button("저장") {
                        withAnimation{ showDatePicker = false }
                    }
                    .foregroundColor(Color.accentColor)
                }
                .padding(.top,30)
                .padding(.trailing, 20)
                
                Picker("납부일", selection: $viewModel.dueDate) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day) 일").tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 200)
                
                Spacer()
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .offset(y: showDatePicker ? geometry.size.height - 250 : geometry.size.height)
            .animation(.easeOut(duration: 0.3), value: showDatePicker)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    BillCreateView()
}
