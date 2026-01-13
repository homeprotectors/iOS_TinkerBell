//
//  ExpandableItemCard.swift
//  DueMate
//
//  Created by Kacey Kim on 9/17/25.
//

import SwiftUI

struct ExpandableItemCard: View {
    let shoppingList: [ShoppingItem]
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            baseLayout
            if isExpanded {
                expandable
                    .transition(.opacity)
            }
            
        }
        
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        
    }
    
    private var baseLayout: some View {
        HStack(spacing: 12) {
            Image("ic_grocery")
                .padding(11)
                .background(.backgroundBlue)
                .cornerRadius(4)
            
            Text("장보기")
                .font(.listTitle)
            
            Spacer()
            
            Text("\(shoppingList.count) 항목")
                .font(.listText)
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
                
            }) {
                Image(isExpanded ? "arrow_up" : "arrow_down")
            }
            .buttonStyle(.plain)
            
        }
    }
    
    private var expandable: some View {
        VStack {
            ForEach(shoppingList) { item in
                Divider()
                HStack {
                    Text(item.name)
                        .font(.listSubitem)
                    
                    Spacer()
                    Text("현재 수량 \(item.currentQuantity)")
                        .font(.listText)
                    Image("stock_lowest")
                    
                }
                .padding(8)
            }
        }
        
    }
}

#Preview {
    ExpandableItemCard(shoppingList: [ShoppingItem(id: 1, name: "빵", currentQuantity: 2, remainingDays: 0),ShoppingItem(id: 2, name: "물티슈", currentQuantity: 1, remainingDays: 0)] )
}
