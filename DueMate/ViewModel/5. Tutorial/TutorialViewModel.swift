//
//  TutorialViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 12/3/25.
//

import Foundation
import UIKit
import SwiftUI

class TutorialViewModel: ObservableObject {
    @Published var selectedItem: HomeItem?
    @Published var selectedItemFrame: CGRect = .zero
    @Published var dragOffset: CGSize = .zero
    
    @Published var firstItem: HomeItem = HomeItem(
        id: 999,
        title: "Dueit 설치하기",
        recurrenceType: "한번",
        selectedCycle: nil,
        roomCategory: "bedroom",
        nextDue: "2026-01-01",
        shoppingContainer: false,
        shoppingItems: nil
    )
    
    func selectItem(_ item: HomeItem, frame: CGRect) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        selectedItemFrame = frame
        withAnimation(.spring(
            response: TutorialAnimation.springResponse,
            dampingFraction: TutorialAnimation.springDamping
        )) {
            selectedItem = item
        }
    }
    
    func clearSelectedItem() {
        withAnimation(.spring(
            response: TutorialAnimation.springResponse,
            dampingFraction: TutorialAnimation.springDamping
        )) {
            selectedItem = nil
            dragOffset = .zero
        }
    }
}

