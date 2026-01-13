//
//  ChoreMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

struct ChoreMainView: View {
    @StateObject private var viewModel = ChoreMainViewModel()
    @State private var selectedItem: ChoreItem? = nil
    @State private var isPresentingCreateSheet: Bool = false
    @State private var itemToDelete: ChoreItem? = nil
    @State private var itemToUpdate: ChoreItem? = nil
    @State private var showDeleteAlert = false
    @State private var plusButtonFrame: CGRect = .zero
    @State private var showTutorialOverlay = true
    
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                headerView
                categoryFilterView
                choreListView
            }
            
            if showTutorialOverlay {
                HighlightOverlayView(message: "예시로 한가지 집안일을 미리 등록해 두었어요!\n자유롭게 수정해서 집안일 주기를 관리해보세요", onDismiss: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        TutorialManager.completeChoreTutorial()
                        showTutorialOverlay = false
                    }
                })
                .transition(.opacity)
            }
        }
        
        //create
        .sheet(isPresented: $isPresentingCreateSheet) {
            ChoreCreateView(onCreate: { viewModel.fetchChores() })
        }
        //update
        .sheet(item: $itemToUpdate) { item in
            ChoreCreateView(onUpdate: {
                viewModel.fetchChores()
            },updateItem: item)
        }
        //delete
        .alert("삭제확인", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                withAnimation{
                    viewModel.deleteChore(id: itemToDelete!.id)
                }
            }
            Button("취소", role: .cancel) { }
        }
        message: {
            Text("\(itemToDelete?.title ?? "")을(를) 정말 삭제하시겠습니까?")
        }
        .onAppear {
            viewModel.fetchChores()
            if !TutorialManager.isChoreTutorialCompleted {
                showTutorialOverlay = true
            }
        }
        .onChange(of: viewModel.shouldRefresh) {
            if viewModel.shouldRefresh {
                print("shouldRefresh == true")
                viewModel.fetchChores()
                viewModel.shouldRefresh = false
            }
        }
        
        .withErrorToast()   //error handler
    }
    
    private var headerView: some View {
        HStack{
            Text("Chores")
                .font(.headerTitle)
                .foregroundColor(.accentColor)
            Spacer()
            Button {
                isPresentingCreateSheet = true
            }label: {
                Image(.plus)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .background(Color.clear)
        .padding(.horizontal, 22)
        .padding(.top, 22)
    }
    
    private var categoryFilterView: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(Constants.categoryOptions) { option in
                        CategoryFilterButton(option: option, isSelected: viewModel.selectedCategory == option.value, onTap: {
                            if viewModel.selectedCategory == option.value {
                                viewModel.selectedCategory = nil
                            }else {
                                viewModel.selectedCategory = option.value
                            }
                        })
                    }
                }
                .padding(.horizontal,12)
                .padding(.vertical,15)
            }
            Divider()
        }
        
    }
    
    private var choreListView: some View {
        List {
            ForEach(viewModel.filteredItems) { item in
                ChoreItemCard(item: item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        SwipeActionButtons(
                            onEdit: { itemToUpdate = item },
                            onDelete: {
                                itemToDelete = item
                                showDeleteAlert = true
                               }
                        )
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
    }
}

#Preview {
    ChoreMainView()
}
