//
//  AppNavigationState.swift
//  DueMate
//
//  Created by Kacey Kim on 3/7/26.
//

import Combine
import Foundation

enum AppTab: Hashable {
    case home
    case chores
    case stocks
}

@MainActor
final class AppNavigationState: ObservableObject {
    static let shared = AppNavigationState()
    
    @Published var selectedTab: AppTab
    
    init(selectedTab: AppTab = .home) {
        self.selectedTab = selectedTab
    }
    
    func handlePushNotification(_ payload: PushNotificationPayload) {
        switch payload.type {
        case .dailyChoreReminder:
            selectedTab = .home
        }
    }
}
