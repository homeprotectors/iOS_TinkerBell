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
            NavigationStack{
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
                .padding()
                .padding(.top, 30)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.items) { item in
                            NavigationLink {
                                ChoreDetailView(item: item)
                                    .environmentObject(viewModel)
                            }label: {
                                ChoreItemView(item: item, color: viewModel.getListColor(due: item.nextDue), onCheckToggled: {
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
