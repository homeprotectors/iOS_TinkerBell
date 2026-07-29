//
//  PushTokenModel.swift
//  DueMate
//
//  Created by Kacey Kim on 3/7/26.
//

import Foundation

enum PushPlatform: String, Codable {
    case ios = "IOS"
//    case android = "ANDROID"
}

struct RegisterPushTokenRequest: Codable {
    let platform: PushPlatform
    let pushToken: String
}

struct UpdatePushTokenEnabledRequest: Codable {
    let pushToken: String
    let enabled: Bool
}

struct PushTokenRegistrationData: Codable {
    let id: Int
    let platform: PushPlatform
    let enabled: Bool
}

enum PushNotificationType: String, Codable {
    case dailyChoreReminder = "DAILY_CHORE_REMINDER"
}

struct PushNotificationPayload: Equatable {
    let type: PushNotificationType
    let date: String?
    let choreCount: String?
    
    init?(userInfo: [AnyHashable: Any]) {
        guard let rawType = userInfo["type"] as? String,
              let type = PushNotificationType(rawValue: rawType) else {
            return nil
        }
        
        self.type = type
        self.date = userInfo["date"] as? String
        self.choreCount = userInfo["choreCount"] as? String
    }
}
