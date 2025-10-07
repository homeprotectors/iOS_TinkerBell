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
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                ForEach(StockSection.allCases, id:\.self) { section in
                    if let sectionItems = viewModel.sections[section], !sectionItems.isEmpty {
                        Section {
                            LazyVStack(spacing: 8) {
                                ForEach(sectionItems) { item in
                                    StockItemView(item: item, onTapGesture: { item in
                                        
                                        selectedItem = item
                                        selectedQuantity = item.currentQuantity
                                    })
                                }
                            }
                            .padding(.bottom, 20)
                        } header: {
                            HStack{
                                Text(section.title)
                                    .font(.listText)
                                Spacer()
                            }
                            .padding(.horizontal,22)
                            .padding(.bottom, 10)
                            .background(Color.white)
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
