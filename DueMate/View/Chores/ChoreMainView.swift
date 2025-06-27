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
        ZStack {
            ListColor.background
                .ignoresSafeArea()
            NavigationStack{
                VStack{
                    HStack{
                        Text("HOUSEHOLD\nLIST")
                            .font(.system(size: 40, weight: .bold))
                        Spacer()
                        NavigationLink {
                            ChoreCreateView(onComplete:{
                                viewModel.fetchChores()
                            })
                        }label: {
                            Image(systemName: "plus")
                                .font(.system(size: 40))
                                .foregroundStyle(.black)
                        }
                        .padding()
                    }
                    .background(Color.clear)
                    .padding()
                    .padding(.top, 30)
                    
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
                        .background(Color.clear)
                        
                    }
                    .background(Color.clear)
                    .padding()
                }
                .background(Color.clear)
                
            }
            .background(Color.clear)
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
            
            if showDialog, let item = selectedItem {
                ConfirmationDialog(
                    isPresented: $showDialog,
                    type: .mainViewCompletion,
                    onConfirm: {
                        viewModel.completeChore(item)
                    }
                )
            }
        }
        .withErrorToast()
        
    }
}

#Preview {
    ChoreMainView()
}
