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
    let background: Color
    let dotColor: Color
    let isExpandable: Bool
    var onLongPress: (CGRect) -> Void
    @State var currentFrame: CGRect = .zero
    
    init(item: HomeItem, onLongPress: @escaping (CGRect) -> Void = { _ in }) {
        self.item = item
        self.onLongPress = onLongPress
        
        switch item.status {
        case "inProgress":
            self.icon = "ic_\(item.category)"
            self.background = .backgoundBlue
            self.dotColor = .dotBlue
            
        case "overdue":
            self.icon = "ic_\(item.category)"
            self.background = .backgoundBlue
            self.dotColor = .dotRed
            
        default:
            self.icon = "ic_\(item.category)_off"
            self.background = .lightGray
            self.dotColor = .dotGray
        }
        
        if item.shoppingList != nil {
            self.isExpandable = true
        } else {
            self.isExpandable = false
        }
    }
    
    var body: some View {
        if isExpandable {
            ExpandableItemCard(shoppingList: item.shoppingList ?? [])
                .onLongPressGesture {
                    onLongPress(currentFrame)
                }
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
            
        } else {
            itemCard
                .onLongPressGesture {
                    onLongPress(currentFrame)
                }
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
    }
    
    private var itemCard: some View {
        HStack(spacing: 12) {
            Image(icon)
                .padding(11)
                .background(background)
                .cornerRadius(4)
            
            Text(item.title)
                .font(.listTitle)
            
            Spacer()
            
            Text(item.cycle)
                .font(.listText)
            
            Rectangle()
                .frame(width: 10, height: 10)
                .cornerRadius(2)
                .foregroundColor(dotColor)
            
        }
    }
    
    func getCurrentFrame() -> CGRect {
        
        
        return .zero
    }
}

#Preview {
    HomeItemView(item: HomeItem(id: 1, title: "빨래", status: "overdue", category: "bedroom", cycle: "한달에 1 번", shoppingList:[ShoppingItem(id: 1, name: "빵", currentQuantity: 2),ShoppingItem(id: 2, name: "빵", currentQuantity: 2)]))
}
