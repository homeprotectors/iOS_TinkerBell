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
    var onLongPress: (CGRect) -> Void
    @Binding var isExpanded: Bool 
    @State var currentFrame: CGRect = .zero
    
    var body: some View {
        VStack {
            baseLayout
            if isExpanded {
                expandable
                    .transition(.opacity)
            }
            
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        let frame = geometry.frame(in: .global)
                        if frame.width > 0 && frame.height > 0 {
                            print(currentFrame)
                            currentFrame = frame
                        }
                    }
                    .onChange(of: geometry.frame(in: .global)) {
                        let frame = geometry.frame(in: .global)
                        if frame.width > 0 && frame.height > 0 {
                            currentFrame = frame
                        }
                    }
            }
        )
        
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        
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
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        onLongPress(currentFrame)
                    }
            )
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
                
            }) {
                Image(isExpanded ? "arrow_up" : "arrow_down")
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            
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
        .opacity(isExpanded ? 1 : 0)
        .clipped()

    }
}

//#Preview {
//    HomeExpandableItemView(item: HomeItem(id: 1, title: "장보기", recurrenceType: nil, selectedCycle: nil, roomCategory: nil, nextDue: nil, shoppingContainer: true, shoppingItems: [
//        ShoppingItem(id: 1, name: "식빵", currentQuantity: 2, remainingDays: 1),
//        ShoppingItem(id: 2, name: "계란", currentQuantity: 2, remainingDays: 1),
//    ]), shoppingList: [
//        ShoppingItem(id: 1, name: "식빵", currentQuantity: 2, remainingDays: 1),
//        ShoppingItem(id: 2, name: "계란", currentQuantity: 2, remainingDays: 1),
//    ], onLongPress: {_ in }, isExpanded: )
//}
