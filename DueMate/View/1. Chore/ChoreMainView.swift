//
//  ChoreMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

struct ChoreMainView: View {
    @StateObject private var viewModel = ChoreMainViewModel()
    @State private var showDialog = false
    @State private var selectedItem: ChoreItem? = nil
    
    var body: some View {
        
        NavigationStack{
            ZStack{
                // background color
//                ListColor.background
//                    .ignoresSafeArea()
                
                // main content
                VStack{
                    headerView
                    choreListView
                }
            }
        }
        .onAppear {
            viewModel.fetchChores()
        }
        .onChange(of: viewModel.shouldRefresh) {
            if viewModel.shouldRefresh {
                print("main refresh")
                viewModel.fetchChores()
                viewModel.shouldRefresh = false
            }
        }
        .overlay {
            dialogView
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDialog)
        .withErrorToast()   //error handler
    }
    
    private var headerView: some View {
        HStack{
            Text("TODO")
                .font(.system(size: 50, weight: .heavy))
            Spacer()
            NavigationLink {
                ChoreCreateView(onComplete:{
                    viewModel.fetchChores()
                })
            }label: {
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.black)
            }
            .padding()
        }
        .padding()
        .padding(.top, 30)
    }
    
    private var choreListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        ChoreDetailView(item: item)
                            .environmentObject(viewModel)
                    }label: {
                        ChoreItemView(item: item, onCheckToggled: {
                            selectedItem = item
                            showDialog = true
                        } )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
    
    private var dialogView: some View {
        Group {
            if showDialog, let item = selectedItem {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        showDialog = false
                    }
                
                ConfirmationDialog(
                    isPresented: $showDialog,
                    type: .mainViewCompletion,
                    onConfirm: {
                        viewModel.completeChore(item)
                    }
                )
                .transition(.scale.combined(with: .opacity))
                
            }
        }
    }
}

#Preview {
    ChoreMainView()
}
