//
//  SplashScreen.swift
//  DueMate
//
//  Created by Kacey Kim on 12/17/25.
//

import SwiftUI
import Lottie


struct SplashScreen: UIViewRepresentable {
    var animationFile = "SplashAnimation"
    var loopMode: LottieLoopMode
    func makeUIView(context: Context) -> UIView {
        let animationView = LottieAnimationView(name: animationFile)
        animationView.play()
        
        return animationView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    typealias UIViewType = UIView
 
}
