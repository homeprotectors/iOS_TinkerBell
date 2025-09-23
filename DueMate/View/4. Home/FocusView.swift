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
    
    var body: some View {
        ZStack {
            HomeItemView(item: item)
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
    FocusView(item: HomeItem(id: 1, title: "화장실 청소", status: "overdue", category: "washroom", cycle: "한달에 1 번", shoppingList: nil ), dragOffset: .zero, onDragChanged: {_ in }, onDragEnded: {_ in }, onDismiss: {})
}
