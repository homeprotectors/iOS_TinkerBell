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
    @State private var isPresentingCreate = false
    @State private var isPresentingWheel = false
    
    var body: some View {
        VStack{
            headerView
            stockListView
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
        .padding(22)
        .sheet(isPresented: $isPresentingCreate) {
            StockCreateView(onComplete: {
                viewModel.fetchStocks()
                isPresentingCreate = false
            })
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isPresentingWheel) {
            if selectedItem != nil {
                
            }
        }
        
    }
    
    private var stockListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(StockSection.allCases, id:\.self) { section in
                    if let sectionItems = viewModel.sections[section], !sectionItems.isEmpty {
                        Section {
                            LazyVStack(spacing: 8) {
                                ForEach(sectionItems) { item in
                                    StockItemView(item: item, onTapGesture: { item in
                                        selectedItem = item
                                        isPresentingWheel = true
                                    })
                                }
                            }
                        } header: {
                            Text(section.title)
                                .font(.listText)
                                .padding(.horizontal,22)
                        }
                    }
                }
            }
        }
        
    }
}

#Preview {
    StockMainView()
}
