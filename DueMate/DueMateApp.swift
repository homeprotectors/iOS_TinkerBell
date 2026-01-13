//
//  DueMateApp.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

@main
struct DueMateApp: App {
    @AppStorage("tutorialCompleted") private var isTutorialCompleted = false
    @State private var showSplash = true
    init() {
        TutorialManager.resetTutorial()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isTutorialCompleted {
                    MainTabView()
                } else {
                    TutorialView()
                }
                
                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                }
                
            }
            
        }
    }
}
