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
    var onLongPress: (CGRect) -> Void
    @State var currentFrame: CGRect = .zero
    
    init(item: HomeItem,  onLongPress: @escaping (CGRect) -> Void = { _ in }) {
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
                            .onAppear {
                                let frame = geometry.frame(in: .global)
                                if frame.width > 0 && frame.height > 0 {
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
        }
        
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    onLongPress(currentFrame)
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
            
            Text(CycleStringBuilder.makeDisplayText(recurrenceType: item.recurrenceType, selectedCycle: item.selectedCycle))
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
