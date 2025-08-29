//
//  BillMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 8/5/25.
//

import SwiftUI

struct BillMainView: View {
    @StateObject private var viewModel = BillMainViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    headerView
                    summaryView
                    billListView
                }
            }
            .padding()
        }
        
        
    }
    
    private var headerView: some View {
        HStack{
            Text("BILL")
                .font(.system(size: 50, weight: .heavy))
            Spacer()
            NavigationLink {
                BillCreateView(onComplete:{
                    viewModel.fetchBills()
                })
            }label: {
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.black)
            }
            .padding()
        }
        
        
    }
    
    private var summaryView: some View {
        HStack {
            Text(Date().toMonthTitle())
                .font(.system(size: 30, weight: .heavy))
            Spacer()
            Text("120,000원")
                .font(.system(size: 20, weight: .medium))
        }
        .padding()
        .background(Color.normal)
        .cornerRadius(20)
        
    }
    
    private var billListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        //
                    }label: {
                        BillItemView(item: item, onCheckToggled: {})
                    }
                    .buttonStyle(.plain)
                    
                }
            }
        }
        .padding()
    }
}

#Preview {
    BillMainView()
}
