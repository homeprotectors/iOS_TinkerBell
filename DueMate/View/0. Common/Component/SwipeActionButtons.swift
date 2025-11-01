//
//  SwipeActionButtons.swift
//  DueMate
//
//  Created by Kacey Kim on 10/10/25.
//

import SwiftUI

struct SwipeActionButtons: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    
    var body: some View {
        Group {
            Button(action: onDelete) {
                Text("삭제")
            }
            .tint(Color.dotRed)
            
            
            Button(action: onEdit) {
                VStack {
                    Text("수정")
                }
            }
            .tint(Color.darkBlueGray)
        }
        
    }
}

#Preview {
    SwipeActionButtons(
//        item: StockItem(id: 1, name: "휴지", unitDays: 3, unitQuantity: 1, currentQuantity: 10, remainingDays: 30),
        onEdit: {}, onDelete: {})
}
