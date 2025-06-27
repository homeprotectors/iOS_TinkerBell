//
//  StockMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockMainView: View {
    @StateObject private var viewModel = StockMainViewModel()
    @State private var showDialog = false
    @State private var selectedItem: StockItem? = nil
    
    var body: some View {
        ZStack {
            ListColor.background
                .ignoresSafeArea()
            NavigationStack{
                VStack{
                    HStack{
                        Text("STOCK\nLIST")
                            .font(.system(size: 40, weight: .bold))
                        Spacer()
                        NavigationLink {
                            StockCreateView(onComplete:{
                                viewModel.fetchStocks()
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
                                   
                                }label: {
                                    StockItemView(item: item, onCheckToggled: {
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
                viewModel.fetchStocks()
            }
            .onChange(of: viewModel.shouldRefresh) {
                if viewModel.shouldRefresh {
                    print("main refresh")
                    viewModel.fetchStocks()
                    viewModel.shouldRefresh = false
                }
            }
            
            if showDialog, let item = selectedItem {
                ConfirmationDialog(
                    isPresented: $showDialog,
                    type: .mainViewCompletion,
                    onConfirm: {
                        
                    }
                )
            }
        }
        .withErrorToast()
    }
}

#Preview {
    StockMainView()
}
