//
//  FocusView.swift
//  DueMate
//
//  Created by Kacey Kim on 9/19/25.
//

import SwiftUI

struct FocusView: View {
    let item: HomeItem
    let dragOffset: CGSize
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: (CGSize) -> Void
    let onDismiss: () -> Void
    @State private var isExpanded: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if item.shoppingContainer {
                    HomeExpandableItemView(item: item, shoppingList: item.shoppingItems ?? [], onLongPress: { _ in  }, isExpanded: $isExpanded)
                    
                } else {
                    HomeItemView(item: item)
                }
            }
            .padding()
            .offset(y: dragOffset.height)
            .gesture (
                DragGesture()
                    .onChanged { value in
                        onDragChanged(value.translation)
                    }
                    .onEnded { value in
                        onDragEnded(value.translation)
                    }
            )
            
        }
    }
}



#Preview {
    FocusView(item: HomeItem(id: 1, title: "장보기", recurrenceType: nil, selectedCycle: nil, roomCategory: nil, nextDue: nil, shoppingContainer: true, shoppingItems: [
        ShoppingItem(id: 1, name: "식빵", currentQuantity: 2, remainingDays: 1),
        ShoppingItem(id: 2, name: "계란", currentQuantity: 2, remainingDays: 1),
    ]), dragOffset: .zero, onDragChanged: {_ in }, onDragEnded: {_ in }, onDismiss: {})
}
