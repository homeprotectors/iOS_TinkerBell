//
//  StockMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockMainView: View {
    @StateObject private var viewModel = StockMainViewModel()
    @State private var selectedItem: StockItem? = nil
    @State private var selectedQuantity: Int = 0
    @State private var isPresentingCreate = false
    @State private var itemToDelete: StockItem? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack {
            headerView
            stockListView
        }
        .confirmationDialog("삭제확인", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                withAnimation{
                    viewModel.deleteItem(id: itemToDelete!.id)
                }
            }
            Button("취소", role: .cancel) { }
        }
        message: {
            Text("\(itemToDelete?.name ?? "")을(를) 정말 삭제하시겠습니까?")
        }
        .onAppear {
            viewModel.fetchStocks()
        }
        .withErrorToast()
    }
    
    
    private var headerView: some View {
        HStack{
            Text("Stocks")
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
        .padding(.horizontal, 22)
        .padding(.top, 22)
        .sheet(isPresented: $isPresentingCreate) {
            StockCreateView(onComplete: { newItem in
                withAnimation {
                    viewModel.createItem(item: newItem)
                }
                isPresentingCreate = false
            })
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedItem) { item in
            StockQuantityPickerView(
                quantity: $selectedQuantity,
                item: item,
                onSave: { newQuantity in
                    viewModel.updateQuantity(
                        for:item.id,
                        newQuantity: newQuantity)
                    selectedItem = nil
                }
            )
            .presentationDetents([.height(350)])
        }
        
    }
    
    private var stockListView: some View {
        List {
            ForEach(StockSection.allCases, id: \.self) { section in
                if let sectionItems = viewModel.sections[section], !sectionItems.isEmpty {
                    Section {
                        ForEach(sectionItems) { item in
                            StockItemView(item: item, onTapGesture: { tapped in
                                selectedItem = tapped
                                selectedQuantity = max(tapped.currentQuantity, 1)
                            })
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                SwipeActionButtons(item: item,
                                                   onEdit: { print("edit \(item.name)") },
                                                   onDelete: {
                                    itemToDelete = item
                                    showDeleteAlert = true
                                })
                            }
                            
                        }
                    } header: {
                        SectionHeaderView(title: section.title)
                    }
                }
            }
        }
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
        .environment(\.defaultMinListHeaderHeight, 0)
        
        
    }
    
    
    
}

#Preview {
    StockMainView()
}
