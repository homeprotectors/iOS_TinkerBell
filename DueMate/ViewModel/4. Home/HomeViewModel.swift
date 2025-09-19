//
//  HomeViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 9/19/25.
//

import Foundation
import SwiftUI
import UIKit

class HomeViewModel: ObservableObject {
    @Published var homeList: [HomeSection] = []
    @Published var selectedItem: HomeItem? = nil
    @Published var selectedItemFrame: CGRect = .zero
    @Published var dragOffset: CGSize = .zero
    
    private var choreFrames: [Int: CGRect] = [:]
    private var maxFrameCache = 50
    
    func fetchHome() {
        homeList = [
            //이번주 할 일
            HomeSection(id: 0, list: [
                HomeItem(id: 1, title: "부엌 청소", status: "inProgress", category: "kitchen", cycle: "한달에 1 번", shoppingList: nil ),
                HomeItem(id: 3, title: "빨래", status: "overdue", category: "bedroom", cycle: "한달에 1 번", shoppingList:[ShoppingItem(id: 1, name: "계란", currentQuantity: 2),ShoppingItem(id: 2, name: "빵", currentQuantity: 2)]),
                HomeItem(id: 2, title: "빨래", status: "overdue", category: "bedroom", cycle: "한달에 1 번", shoppingList: nil)
            ]),
            
            //나중에 할 일
            HomeSection(id: 1, list: [
                HomeItem(id: 1, title: "화장실 청소", status: "overdue", category: "washroom", cycle: "한달에 1 번", shoppingList: nil ),
                HomeItem(id: 2, title: "화장실 청소", status: "overdue", category: "washroom", cycle: "한달에 1 번", shoppingList: nil )
            ])
        ]
    }
    
    func selecItem(_ item: HomeItem, frame: CGRect) {
        //진동
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        selectedItemFrame = frame
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedItem = item
        }
        
        
    }
    
    
}
