//
//  HomeExpandableItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 1/2/26.
//

import SwiftUI

struct HomeExpandableItemView: View {
    let item: HomeItem
    let shoppingList: [ShoppingItem]
    var onDetailItemTap: ((ShoppingItem) -> Void)? = nil
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            baseLayout
            
            if isExpanded {
                detailContainer
                    .transition(
                        .opacity.combined(with: .scale(scale: 0.97, anchor: .top))
                    )
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var baseLayout: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image("ic_grocery")
                    .padding(11)
                    .background(.backgroundBlue)
                    .cornerRadius(4)
                
                Text("장보기")
                    .font(.listTitle)
                
                Spacer()
                
                Text("\(item.shoppingItems?.count ?? 0) 항목")
                    .font(.listText)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                toggleExpanded()
            }
            
            
            Button(action: {
                toggleExpanded()
            }) {
                Image(isExpanded ? "arrow_up" : "arrow_down")
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(12)
    }
    
    private var detailContainer: some View {
        VStack(spacing: 0) {
            detailRows
                .padding(.horizontal, 12)
        }
        
    }
    
    private var detailRows: some View {
        VStack(spacing: 0) {

            ForEach(shoppingList) { shoppingItem in
                if shoppingItem.id != shoppingList.first?.id {
                    Divider()
                }
                
                HStack {
                    Text(shoppingItem.name)
                        .font(.listSubitem)
                    
                    Spacer()
                    
                    Text("\(shoppingItem.currentQuantity)개")
                        .font(.listText)
                        
                    
                    Image("stock_lowest")
                        .padding(.leading, 5)
                }
                .padding(12)
                .onTapGesture {
                    onDetailItemTap?(shoppingItem)
                }
            }
            
        }
    }
    
    private func toggleExpanded() {
        withAnimation(.easeInOut(duration: 0.22)) {
            isExpanded.toggle()
        }
    }
}
