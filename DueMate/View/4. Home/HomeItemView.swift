//
//  HomeItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 9/16/25.
//

import SwiftUI


struct HomeItemView: View {
    let item: HomeItem
    let icon: String
    var onLongPress: () -> Void
    
    init(item: HomeItem,  onLongPress: @escaping () -> Void = {}) {
        self.item = item
        self.onLongPress = onLongPress
        self.icon = "ic_\(item.roomCategory?.lowercased() ?? "etc")"

    }
    
    var body: some View {
        VStack {
            
            itemCard
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: HomeItemFramePreferenceKey.self,
                                value: [item.id: geometry.frame(in: .global)]
                            )
                    }
                )
        }
        
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    onLongPress()
                }
        )
        
    }
    
    var itemCard: some View {
        HStack(spacing: 12) {
            Image(icon)
                .padding(11)
                .background(Color.backgoundBlue)
                .cornerRadius(4)
            
            Text(item.title)
                .font(.listTitle)
            
            Spacer()
            
            Text(item.recurrenceDescription)
                .font(.listText)
            
            
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        
    }
    
}

#Preview {
    HomeItemView(item: HomeItem(id: 1, title: "빨래", recurrenceType: "PER_WEEK", selectedCycle: nil, roomCategory: nil, nextDue: nil, shoppingContainer: true, shoppingItems: nil))
}
