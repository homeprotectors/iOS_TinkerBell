//
//  StockDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 7/4/25.
//

import SwiftUI

struct StockDetailView: View {
    let item: StockItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainViewModel: StockMainViewModel
    @StateObject private var viewModel = StockDetailViewModel()
    
    @State private var showReminderPicker = false
    @State private var showUnitPicker = false
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    
    @State private var circleScale: CGFloat = 1.0
    @State private var textPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var isExpanded = false
    @State private var tempQuantity: String = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                //title
                TitleTextField(title: $viewModel.title)
                
                //current quantity view
                
                Button(action: {
                    expandCircle()
                }) {
                    ZStack {
                        Circle()
                            .fill(.overdue)
                            .frame(width: 200, height: 200)
                            .scaleEffect(circleScale)
                        
                        Text(viewModel.currentQuantity)
                            .foregroundStyle(.white)
                            .font(.system(size: 48, weight: .bold))
                            .offset(x: textPosition.x, y: textPosition.y)
                    }
                }
                .disabled(isExpanded)
                
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
                .padding(.top, 20)
                .sheet(isPresented: $showUnitPicker) {
                    StockUnitPickerView(
                        quantity: $viewModel.unitQuantityString,
                        unit: $viewModel.unit
                    )
                }
                
                //reminder
                ReminderField(selectedReminder: $viewModel.reminderOptions)
                    .formLabel("알람")
                
                // Save Button
                Spacer()
                Button(action: {
                    //update
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.hasInputChanged() ? Color.blue : .gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(!viewModel.hasInputChanged())
                .onChange(of: viewModel.shoudRedirectMain) {
                    if viewModel.shoudRedirectMain {
                        mainViewModel.shouldRefresh = true
                        dismiss()
                    }
                }
                
                // Delete Button
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Chore")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .alert("이 할 일을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                    Button("삭제", role: .destructive){
                        //삭제
                    }
                    Button("취소",role: .cancel) {}
                }
            }
            .onAppear{
                viewModel.firstInputSetting(item: item)
            }
            .padding(30)
            
            // 확장된 오버레이
            if isExpanded {
                expandedOverlay
            }
        }
    }
    
    var expandedOverlay: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(.overdue)
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                
                VStack(spacing: 35) {
                    Text("지금 얼마나 남아있나요?")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                    
                    TextField("수량", text: $tempQuantity)
                        .keyboardType(.numberPad)
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .frame(width: 200)
                    
                    Button(action: {
                        collapseCircle()
                    }) {
                        Text("저장")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .foregroundColor(.overdue)
                            .clipShape(Capsule())
                    }
                }
                .position(x: geo.size.width/2, y: geo.size.height/2) // 화면 중앙에 고정
            }
        }
        .ignoresSafeArea(.all)
    }
    
    func expandCircle() {
        tempQuantity = viewModel.currentQuantity
        
        let screenSize = UIScreen.main.bounds.size
        let centerPosition = CGPoint(
            x: screenSize.width/2 - 100,
            y: screenSize.height/2 - 100
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            circleScale = 10
            textPosition = centerPosition
            isExpanded = true
        }
    }
    
    func collapseCircle() {
        viewModel.currentQuantity = tempQuantity
        viewModel.saveQuantity()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            circleScale = 1.0
            textPosition = CGPoint(x: 0, y: 0)
            isExpanded = false
        }
    }
}

#Preview {
    StockDetailView(item: StockItem(id: 1, title: "휴지", unitDays: 3, unitQuantity: 1, unit: "개", nextDue: "2025-07-29", reminderDays: 1))
}

