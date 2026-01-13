//
//  SplashView.swift
//  DueMate
//
//  Created by Kacey Kim on 12/18/25.
//

import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            LottieView(
                loopMode: .playOnce,
                onAnimationFinished: {
                    onFinish()
                }
            )
        }
    }
}

#Preview {
    SplashView(onFinish: {print("끝!")})
}
