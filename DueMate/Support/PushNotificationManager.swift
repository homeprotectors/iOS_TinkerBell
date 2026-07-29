//
//  PushNotificationManager.swift
//  DueMate
//
//  Created by Codex on 3/7/26.
//

import Combine
import FirebaseCore
import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationSettingsStore: ObservableObject {
    static let shared = PushNotificationSettingsStore()
    
    @Published private(set) var isNotificationEnabled = false
    @Published private(set) var isLoaded = false
    @Published private(set) var isLoading = false
    @Published private(set) var isUpdating = false
    
    private let network = DefaultNetworkService.shared
    private let tokenStore = PushTokenStore.shared
    private let updateDebounceNanoseconds: UInt64 = 450_000_000
    
    private var lastKnownServerEnabled: Bool?
    private var pendingDesiredEnabled: Bool?
    private var pendingUpdateTask: Task<Void, Never>?
    
    private init() {}
    
    func prefetchAtAppLaunch() async {
        await loadIfNeeded(shouldPresentErrors: false)
    }
    
    func loadIfNeeded(shouldPresentErrors: Bool = true) async {
        guard !isLoaded else { return }
        await refreshFromServer(shouldPresentErrors: shouldPresentErrors)
    }
    
    func refreshFromServer(shouldPresentErrors: Bool = true) async {
        guard !isLoading else { return }
        guard hasRegisteredPushToken else {
            return
        }
        guard let pushToken = currentPushToken else { return }
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        _ = await UserIdentifierManager.shared.prepareSessionIfNeeded()
        guard UserIdentifierManager.shared.authorizationHeaderValue != nil else {
            return
        }
        
        do {
            let data: PushTokenRegistrationData = try await network.request(
                PushRouter.current(pushToken: pushToken)
            )
            applyRemoteEnabledState(data.enabled)
        } catch {
            if shouldPresentErrors {
                await ErrorHandler.shared.handle(error)
            }
        }
    }
    
    func setNotificationEnabled(_ isEnabled: Bool) {
        isNotificationEnabled = isEnabled
        pendingDesiredEnabled = isEnabled
        schedulePendingUpdate()
    }
    
    func reset() {
        pendingUpdateTask?.cancel()
        pendingUpdateTask = nil
        pendingDesiredEnabled = nil
        lastKnownServerEnabled = nil
        isNotificationEnabled = false
        isLoaded = false
        isLoading = false
        isUpdating = false
    }

    func updateFromServerRegistration(enabled isEnabled: Bool) {
        applyRemoteEnabledState(isEnabled)
    }
    
    private func applyRemoteEnabledState(_ isEnabled: Bool) {
        lastKnownServerEnabled = isEnabled
        isNotificationEnabled = isEnabled
        isLoaded = true
    }
    
    private func schedulePendingUpdate(delayNanoseconds: UInt64? = nil) {
        pendingUpdateTask?.cancel()
        
        let effectiveDelay = delayNanoseconds ?? updateDebounceNanoseconds
        pendingUpdateTask = Task { [weak self] in
            guard let self else { return }
            if effectiveDelay > 0 {
                try? await Task.sleep(nanoseconds: effectiveDelay)
            }
            guard !Task.isCancelled else { return }
            await self.flushPendingUpdateIfNeeded()
        }
    }
    
    private func flushPendingUpdateIfNeeded() async {
        guard !isUpdating else { return }
        guard let desiredEnabled = pendingDesiredEnabled else { return }
        
        guard desiredEnabled != lastKnownServerEnabled else {
            pendingDesiredEnabled = nil
            return
        }
        
        guard let pushToken = currentPushToken else {
            pendingDesiredEnabled = nil
            isNotificationEnabled = lastKnownServerEnabled ?? false
            await ErrorHandler.shared.handle(
                NetworkError.data("푸시 토큰을 아직 받을 수 없습니다.\n잠시 후 다시 시도해주세요.")
            )
            return
        }
        
        isUpdating = true
        pendingDesiredEnabled = nil
        
        defer {
            isUpdating = false
            if let pendingDesiredEnabled,
               pendingDesiredEnabled != lastKnownServerEnabled {
                schedulePendingUpdate(delayNanoseconds: 0)
            }
        }
        
        do {
            try await network.requestWithoutResponse(
                PushRouter.updateEnabled(
                    body: UpdatePushTokenEnabledRequest(
                        pushToken: pushToken,
                        enabled: desiredEnabled
                    )
                )
            )
            applyRemoteEnabledState(desiredEnabled)
        } catch {
            if pendingDesiredEnabled == nil {
                isNotificationEnabled = lastKnownServerEnabled ?? false
            }
            await ErrorHandler.shared.handle(error)
        }
    }
    
    private var currentPushToken: String? {
        normalized(tokenStore.currentFCMToken) ?? normalized(tokenStore.lastSyncedFCMToken)
    }

    private var hasRegisteredPushToken: Bool {
        tokenStore.pushTokenRecordId != nil && currentPushToken != nil
    }
    
    private func normalized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}

final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    
    private let tokenStore = PushTokenStore.shared
    private let network = DefaultNetworkService.shared
    private let stateQueue = DispatchQueue(label: "com.duemate.push.state")
    
    private var isFirebaseConfigured = false
    private var hasReceivedAPNsToken = false
    private var isSyncInProgress = false
    
    private override init() {
        super.init()
    }
    
    func configureFirebaseIfPossible() {
        let isAlreadyConfigured = stateQueue.sync { isFirebaseConfigured }
        guard !isAlreadyConfigured else { return }
        
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return
        }
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        stateQueue.sync {
            isFirebaseConfigured = true
        }
    }
    
    func start() async {
        guard stateQueue.sync(execute: { isFirebaseConfigured }) else {
            return
        }
        
        await requestAuthorizationIfNeeded()
    }
    
    func handleAPNsDeviceToken(_ deviceToken: Data) {
        guard stateQueue.sync(execute: { isFirebaseConfigured }) else { return }
        stateQueue.sync {
            hasReceivedAPNsToken = true
        }
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { [weak self] token, error in
            if error != nil { return }
            self?.handleFCMToken(token)
        }
    }
    
    func handleRemoteNotificationRegistrationFailure(_ error: Error) {}
    
    func deleteRegisteredPushTokenIfNeeded() async {
        guard let tokenId = tokenStore.pushTokenRecordId else { return }
        
        do {
            try await network.requestWithoutResponse(PushRouter.delete(id: tokenId))
            tokenStore.clearRegistration()
        } catch {}
    }
    
    private func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                guard granted else { return }
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } catch {}
        case .authorized, .provisional, .ephemeral:
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        case .denied:
            break
        @unknown default:
            break
        }
    }
    
    private func scheduleTokenSync() {
        var shouldStartSync = false
        
        stateQueue.sync {
            if isSyncInProgress {
                return
            }
            isSyncInProgress = true
            shouldStartSync = true
        }
        
        guard shouldStartSync else { return }
        
        Task { [weak self] in
            await syncPushTokenIfNeeded()
            self?.stateQueue.sync {
                isSyncInProgress = false
            }
        }
    }
    
    private func syncPushTokenIfNeeded() async {
        let isReadyForSync = stateQueue.sync {
            isFirebaseConfigured && hasReceivedAPNsToken
        }
        guard isReadyForSync else { return }
        guard let currentToken = normalized(tokenStore.currentFCMToken ?? Messaging.messaging().fcmToken) else { return }
        
        _ = await UserIdentifierManager.shared.prepareSessionIfNeeded()
        guard UserIdentifierManager.shared.authorizationHeaderValue != nil else { return }
        
        let lastSyncedToken = tokenStore.lastSyncedFCMToken
        let recordId = tokenStore.pushTokenRecordId
        
        guard currentToken != lastSyncedToken || recordId == nil else {
            return
        }
        
        let body = RegisterPushTokenRequest(platform: .ios, pushToken: currentToken)
        
        do {
            let data: PushTokenRegistrationData = try await network.request(PushRouter.register(body: body))
            let previousRecordId = recordId
            let previousToken = lastSyncedToken
            tokenStore.saveRegistration(recordId: data.id, token: currentToken)
            await PushNotificationSettingsStore.shared.updateFromServerRegistration(enabled: data.enabled)
            
            if let previousRecordId,
               let previousToken,
               previousToken != currentToken,
               previousRecordId != data.id {
                do {
                    try await network.requestWithoutResponse(PushRouter.delete(id: previousRecordId))
                } catch {}
            }
        } catch {}
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let payload = PushNotificationPayload(userInfo: userInfo) else { return }
        
        Task { @MainActor in
            AppNavigationState.shared.handlePushNotification(payload)
        }
    }
    
    private func handleFCMToken(_ rawToken: String?) {
        guard let token = normalized(rawToken) else { return }
        tokenStore.saveCurrentFCMToken(token)
        
        let hasAPNsToken = stateQueue.sync { hasReceivedAPNsToken }
        guard hasAPNsToken else { return }
        
        scheduleTokenSync()
    }
    
    private func normalized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}

extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        handleFCMToken(fcmToken)
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationTap(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
}
