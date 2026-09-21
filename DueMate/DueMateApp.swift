//
//  DueMateApp.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

@main
struct DueMateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("tutorialCompleted") private var isTutorialCompleted = false
    @State private var isSplashAnimationFinished = false
    @State private var bootstrapTask: Task<Void, Never>?
    @StateObject private var navigationState = AppNavigationState.shared

    private var isRunningTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] != nil
            || environment["DUEIT_UNIT_TESTING"] == "1"
    }
    
    init() {
//        UserIdentifierManager.shared.resetIdentifiers() // DEBUG: 저장된 user/install 식별자 리셋, 디버깅 끝나면 주석 처리
        // 앱 시작 시 installId 초기화 (없으면 생성, 있으면 불러오기)
        _ = UserIdentifierManager.shared.getOrCreateInstallId()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashAnimationFinished {
                    if isTutorialCompleted {
                        MainTabView()
                    } else {
                        TutorialView()
                    }
                } else {
                    Color.white.ignoresSafeArea()
                }
                
                if !isSplashAnimationFinished {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.25)) {
                            isSplashAnimationFinished = true
                        }
                    }
                    .transition(.opacity)
                }
                
            }
            .environmentObject(navigationState)
            .task {
                guard !isRunningTests else { return }
                startBootstrapIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestAppRelaunch)) { _ in
                relaunchFromSplash()
            }
        }
    }
    
    @MainActor
    private func startBootstrapIfNeeded() {
        guard bootstrapTask == nil else { return }
        
        bootstrapTask = Task {
            defer {
                Task { @MainActor in
                    bootstrapTask = nil
                }
            }
            
            _ = await UserIdentifierManager.shared.prepareSessionIfNeeded()
            guard !Task.isCancelled else { return }
            
            await PushNotificationManager.shared.start()
            guard !Task.isCancelled else { return }
            
            await PushNotificationSettingsStore.shared.prefetchAtAppLaunch()
        }
    }
    
    @MainActor
    private func relaunchFromSplash() {
        navigationState.selectedTab = .home
        bootstrapTask?.cancel()
        bootstrapTask = nil
        isSplashAnimationFinished = false
        startBootstrapIfNeeded()
    }
}
