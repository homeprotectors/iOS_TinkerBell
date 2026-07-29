//
//  StockMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockMainView: View {
    @EnvironmentObject private var stockStore: StockStore
    @State private var selectedItem: StockItem? = nil
    @State private var selectedQuantity: Int = 0
    @State private var isPresentingCreate = false
    @State private var itemToDelete: StockItem? = nil
    @State private var itemToUpdate: StockItem? = nil
    @State private var showDeleteAlert = false
    @State private var showTutorialOverlay = !TutorialManager.isStockTutorialCompleted
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                stockListView
            }
            
            if showTutorialOverlay {
                HighlightOverlayView(message: "예시로 하나의 소모품을 등록해두었어요.\n정기적으로 사용하는 물품을 등록하면 소진 시기에 맞춰 장보기 할 일이 자동으로 생성돼요.", onDismiss: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        TutorialManager.completeStockTutorial()
                        showTutorialOverlay = false
                    }
                })
                .transition(.opacity)
            }
            
        }
        //create
        .sheet(isPresented: $isPresentingCreate) {
            StockCreateView(onSave: { draft in
                let didCreate = await stockStore.create(from: draft)
                if didCreate {
                    isPresentingCreate = false
                }
                return didCreate
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        //update
        .sheet(item: $itemToUpdate) { item in
            StockCreateView(onSave: { draft in
                let didUpdate = await stockStore.updateInfo(
                    id: item.id,
                    draft: draft,
                    currentQuantity: item.currentQuantity
                )
                if didUpdate {
                    itemToUpdate = nil
                }
                return didUpdate
            }, updateItem: item)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        //update quantity
        .sheet(item: $selectedItem) { item in
            StockQuantityPickerView(
                quantity: $selectedQuantity,
                item: item,
                onSave: { newQuantity in
                    Task {
                        await stockStore.updateQuantity(
                            for: item.id,
                            newQuantity: newQuantity
                        )
                    }
                }
            )
            .presentationDetents([.height(350)])
        }
        .alert("삭제확인", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                guard let itemToDelete else { return }
                Task {
                    await stockStore.delete(id: itemToDelete.id)
                }
            }
            Button("취소", role: .cancel) { }
        }
        message: {
            Text("\(itemToDelete?.name ?? "")을(를) 정말 삭제하시겠습니까?")
        }
        .task {
            await stockStore.loadIfNeeded()
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
        .padding(.horizontal, 22)
        .padding(.top, 22)
        
    }
    
    private var stockListView: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if stockStore.items.isEmpty && !stockStore.isLoading {
                EmptyShadeLogoView()
            }
            
            if stockStore.isLoading && stockStore.items.isEmpty {
                ProgressView()
            }

            List {
                ForEach(StockSection.allCases, id: \.self) { section in
                    if let sectionItems = stockStore.sections[section], !sectionItems.isEmpty {
                        Section {
                            ForEach(sectionItems) { item in
                                StockItemView(item: item, onTapGesture: { tapped in
                                    selectedItem = tapped
                                    selectedQuantity = max(tapped.currentQuantity, 1)
                                })
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.white)
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
                            SectionHeaderView(title: section.title)
                               
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .refreshable {
                await stockStore.refresh()
            }
            .background(Color.white)
        }
        .listStyle(.plain)
        .listSectionSpacing(35)
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
        .environment(\.defaultMinListHeaderHeight, 0)
    }
    
}

#Preview {
    StockMainView()
        .environmentObject(StockStore.shared)
}
