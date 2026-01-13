//
//  BillMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 8/5/25.
//

import SwiftUI

struct BillMainView: View {
    @StateObject private var viewModel = BillMainViewModel()
    @State private var isPresentingCreate = false
    @State private var selectedVariableBill: BillItem? = nil
    @State private var variableAmount: Double? = nil
    @State private var itemToDelete: BillItem? = nil
    @State private var itemToUpdate: BillItem? = nil
    @State private var showDeleteAlert: Bool = false
    @State private var showTutorialOverlay = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                monthPickerView
                summaryView
                billListView
            }
            
            if showTutorialOverlay {
                HighlightOverlayView(message: "매달 발생하는 고정 지출을 등록해 간편하게 관리해보세요!\n공과금처럼 매달 변동되는 비용도 한 곳에서 확인할 수 있어요.", onDismiss: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        TutorialManager.completeBillTutorial()
                        showTutorialOverlay = false
                    }
                })
                .transition(.opacity)
            }
        
        }
        .onAppear {
            viewModel.fetchBills()
            if !TutorialManager.isBillTutorialCompleted {
                showTutorialOverlay = true
            }
        }
        //create
        .sheet(isPresented: $isPresentingCreate) {
            BillCreateView()
                .presentationDetents([.large])
        }
        //update
        .sheet(item: $itemToUpdate) { item in
            BillCreateView(updateItem: item)
                .presentationDetents([.large])
        }
        
        //variable form
        .sheet(item: $selectedVariableBill) { bill in
            VariableBillView(item: bill, month: viewModel.monthInt, onSave: { amount in
                viewModel.updateVariableBill(id: bill.id, amount: amount)
            })                .presentationDetents([.height(200)])
        }
        .presentationDragIndicator(.hidden)
        .alert("\(itemToDelete?.name ?? "")", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                withAnimation{
                    viewModel.deleteBill(id: itemToDelete!.id)
                }
            }
            Button("취소", role: .cancel) { }
        }
        message: {
            Text("지난달까지의 기록은 그대로 남아 있어요.\n이번 달부터만 목록에서 제외됩니다.\n 삭제할까요?")
        }
        .withErrorToast()
        
    }
    
    private var headerView: some View {
        HStack{
            Text("Bills")
                .font(.headerTitle)
                .foregroundColor(.accentColor)
            Spacer()
            Button {
                isPresentingCreate = true
            }label: {
                Image(.plus)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            
        }
        .background(Color.clear)
        .padding(22)
        
    }
    
    private var monthPickerView: some View {
        HStack {
            Button(action: {viewModel.changeMonth(by: -1)}) {
                Image("arrow_left")
                    .padding(10)
            }
            Spacer()
            Text(viewModel.currentMonth.toMonthTitle())
                .font(.listTitle)
            Spacer()
            Button(action: {viewModel.changeMonth(by: 1)}) {
                Image("arrow_right")
                    .padding(10)
            }
            .opacity(viewModel.isCurrentMonth ? 0.3 : 1)
            .disabled(viewModel.isCurrentMonth)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }
    
    private var summaryView: some View {
        HStack {
            Text("총 고정지출 : \(viewModel.total, format: .currency(code: "KRW"))")
                .font(.listTitle)
            
            Spacer()
            differenceText
                .font(.listSubitem)
        }
        .padding(20)
        .background(Color.backgroundGray)

    }
    
    private var billListView: some View {
        List {
            ForEach(viewModel.items) { section in
                Section {
                    ForEach(section.list) { item in
                        BillItemView(item: item, onTapped: {
                            selectedVariableBill = item
                        })
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                SwipeActionButtons(
                                    
                                    onEdit: { itemToUpdate = item },
                                    onDelete: {
                                        itemToDelete = item
                                        showDeleteAlert = true }
                                )
                            }
                            
                    }
                } header: {
                    Text(section.header)
                        .font(.listText)
                }
                
            }
                
            
        }
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
        .environment(\.defaultMinListHeaderHeight, 0)
    }
    
    private var differenceText: Text {
        
        let diff = abs(viewModel.difference)
        var signSymbol = ""
        var textColor = Color.black
        
        if viewModel.difference > 0 {
            signSymbol = "▲"
            textColor = Color.dotRed
        } else if viewModel.difference < 0 {
            signSymbol = "▼"
            textColor = Color.dotBlue
        } else {
            return Text("지난달과 동일해요!")
        }
        
        
        
        let result = Text("지난달에 비해 ").foregroundColor(Color.primaryText) +
        Text("\(diff.formatted( .currency(code: "KRW"))) \(signSymbol)").foregroundColor(textColor)
        
        return result
    }
    
}

#Preview {
    BillMainView()
}
