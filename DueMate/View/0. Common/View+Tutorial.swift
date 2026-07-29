//
//  View+Tutorial.swift
//  DueMate
//
//  Created by Kacey Kim on 12/XX/25.
//

import SwiftUI

extension View {
    /// 탭 튜토리얼을 추가하는 View Modifier
    func tabTutorial(
        showOverlay: Binding<Bool>,
        buttonFrame: Binding<CGRect>,
        config: TabTutorialConfig
    ) -> some View {
        self
            .onPreferenceChange(ButtonFramePreferenceKey.self) { frame in
                if frame != .zero {
                    buttonFrame.wrappedValue = frame
                }
            }
            .onAppear {
                if !config.isCompleted() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showOverlay.wrappedValue = true
                    }
                }
            }
    }
}

struct ButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
