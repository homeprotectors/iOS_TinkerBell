//
//  PlusButtonWithTutorial.swift
//  DueMate
//
//  Created by Kacey Kim on 12/XX/25.
//

import SwiftUI

/// 튜토리얼 기능이 있는 Plus 버튼
struct PlusButtonWithTutorial: View {
    let onTap: () -> Void
    let showTutorialOverlay: Bool
    let onTutorialDismiss: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(.plus)
                .resizable()
                .frame(width: 24, height: 24)
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ButtonFramePreferenceKey.self,
                        value: geometry.frame(in: .global)
                    )
            }
        )
    }
}
