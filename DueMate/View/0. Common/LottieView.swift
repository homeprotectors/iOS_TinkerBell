//
//  LottieView.swift
//  DueMate
//
//  Created by Kacey Kim on 12/17/25.
//

import SwiftUI
import Lottie


struct LottieView: UIViewRepresentable {
    var animationFile = "SplashAnimation"
    var loopMode: LottieLoopMode
    var onAnimationFinished: (() -> Void)
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView(name: animationFile)
        animationView.contentMode = .scaleAspectFit
        
        //UIKit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        animationView.play { finished in
            if finished {
                onAnimationFinished()
            }
        }

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    typealias UIViewType = UIView
 
}
