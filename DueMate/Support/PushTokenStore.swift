//
//  PushTokenStore.swift
//  DueMate
//
//  Created by Codex on 3/7/26.
//

import Foundation

final class PushTokenStore {
    static let shared = PushTokenStore()
    
    private enum Keys {
        static let currentFCMToken = "currentFCMToken"
        static let pushTokenRecordId = "pushTokenRecordId" // for delete
        static let lastSyncedFCMToken = "lastSyncedFCMToken"
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var currentFCMToken: String? {
        normalized(userDefaults.string(forKey: Keys.currentFCMToken))
    }
    
    var pushTokenRecordId: Int? {
        guard userDefaults.object(forKey: Keys.pushTokenRecordId) != nil else { return nil }
        return userDefaults.integer(forKey: Keys.pushTokenRecordId)
    }
    
    var lastSyncedFCMToken: String? {
        normalized(userDefaults.string(forKey: Keys.lastSyncedFCMToken))
    }
    
    func saveCurrentFCMToken(_ token: String) {
        userDefaults.set(token, forKey: Keys.currentFCMToken)
    }
    
    func saveRegistration(recordId: Int, token: String) {
        userDefaults.set(recordId, forKey: Keys.pushTokenRecordId)
        userDefaults.set(token, forKey: Keys.lastSyncedFCMToken)
        userDefaults.set(token, forKey: Keys.currentFCMToken)
    }
    
    func clearRegistration() {
        userDefaults.removeObject(forKey: Keys.pushTokenRecordId)
        userDefaults.removeObject(forKey: Keys.lastSyncedFCMToken)
    }
    
    private func normalized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}
