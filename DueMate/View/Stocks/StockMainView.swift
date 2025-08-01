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
    
    var body: some View {
        ZStack {
//                        ListColor.background
//                            .ignoresSafeArea()
            NavigationStack{
                VStack{
                    headerView
                    stockListView
                }
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
        }
        .withErrorToast()
    }
    
    private var headerView: some View {
        HStack{
            Text("TOBUY")
                .font(.system(size: 50, weight: .heavy))
            Spacer()
            NavigationLink {
                StockCreateView(onComplete:{
                    viewModel.fetchStocks()
                })
            }label: {
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.black)
            }
            .padding()
        }
        .background(Color.clear)
        .padding()
        .padding(.top, 30)
    }
    
    private var stockListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        StockDetailView(item: item)
                            .environmentObject(viewModel)
                    }label: {
                        StockItemView(item: item)
                        
                    }
                    .buttonStyle(.plain)
                    
                }
            }
        }
        .padding()
    }
}

#Preview {
    StockMainView()
}
