//
//  UserIdentifierManager.swift
//  DueMate
//
//  Created by Kacey Kim on 12/XX/25.
//

import Foundation

extension Notification.Name {
    static let didRequestAppRelaunch = Notification.Name("didRequestAppRelaunch")
}

/// installId와 guest 인증 토큰을 관리하는 싱글톤 매니저
/// installId는 생성/보존하고, 서버에서 발급받은 access/refresh token은 Keychain에 저장합니다.
final class UserIdentifierManager {
    
    private struct SessionMetadata: Codable {
        let userId: String?
        let tokenType: String
        let accessTokenExpiresAt: Date
    }
    
    private enum SessionRefreshResult {
        case success
        case needsRegistration
        case unavailable
    }
    
    static let shared = UserIdentifierManager()
    
    private let keychainHelper = KeychainHelper.self
    private let userDefaults = UserDefaults.standard
    private let stateQueue = DispatchQueue(label: "com.duemate.userIdentifier.state")
    
    private static let fallbackInstallIdKey = "fallbackInstallId"
    private static let sessionMetadataKey = "guestSessionMetadata"
    private static let accessTokenRefreshLeeway: TimeInterval = 60
    private static let defaultAccessTokenLifetime: TimeInterval = 300
    
    private var cachedInstallId: String?
    private var cachedAccessToken: String?
    private var cachedRefreshToken: String?
    private var cachedSessionMetadata: SessionMetadata?
    private var sessionPreparationTask: Task<Bool, Never>?
    private var sessionRecoveryTask: Task<Bool, Never>?
    
    /// 앱 설치 식별자 (installId)
    var installId: String {
        getOrCreateInstallId()
    }
    
    /// 서버에서 발급받아 저장된 access token
    var accessToken: String? {
        stateQueue.sync { cachedAccessToken }
    }
    
    /// 서버에서 발급받아 저장된 refresh token
    var refreshToken: String? {
        stateQueue.sync { cachedRefreshToken }
    }
    
    /// 모든 인증 요청에 사용할 Authorization 헤더 값
    var authorizationHeaderValue: String? {
        stateQueue.sync {
            guard let accessToken = normalized(cachedAccessToken) else {
                return nil
            }
            
            let tokenType = normalized(cachedSessionMetadata?.tokenType) ?? "Bearer"
            return "\(tokenType) \(accessToken)"
        }
    }
    
    /// 인증 가능한 세션이 준비되었는지 여부
    var hasActiveSession: Bool {
        authorizationHeaderValue != nil && !needsAccessTokenRefresh
    }
    
    var needsAccessTokenRefresh: Bool {
        stateQueue.sync {
            shouldRefreshAccessTokenLocked(referenceDate: Date())
        }
    }
    
    private init() {
        let storedInstallId = normalized(keychainHelper.loadInstallId())
            ?? normalized(userDefaults.string(forKey: Self.fallbackInstallIdKey))
        let storedAccessToken = normalized(keychainHelper.loadAccessToken())
        let storedRefreshToken = normalized(keychainHelper.loadRefreshToken())
        let storedSessionMetadata = loadSessionMetadata()
            ?? deriveSessionMetadataFromStoredAccessToken(storedAccessToken)
        
        stateQueue.sync {
            cachedInstallId = storedInstallId
            cachedAccessToken = storedAccessToken
            cachedRefreshToken = storedRefreshToken
            cachedSessionMetadata = storedSessionMetadata
        }
        
        migrateFallbackToKeychainIfNeeded()
    }
    
    /// installId를 가져오거나 생성합니다.
    /// Keychain에 저장된 installId가 있으면 반환하고, 없으면 새로 생성하여 저장합니다.
    /// - Returns: installId 문자열
    @discardableResult
    func getOrCreateInstallId() -> String {
        if let cachedInstallId = stateQueue.sync(execute: { cachedInstallId }) {
            return cachedInstallId
        }
        
        if let existingInstallId = normalized(keychainHelper.loadInstallId()) {
            stateQueue.sync {
                cachedInstallId = existingInstallId
            }
            userDefaults.removeObject(forKey: Self.fallbackInstallIdKey)
            return existingInstallId
        }
        
        if let fallbackInstallId = normalized(
            userDefaults.string(forKey: Self.fallbackInstallIdKey)
        ) {
            stateQueue.sync {
                cachedInstallId = fallbackInstallId
            }
            _ = keychainHelper.saveInstallId(fallbackInstallId)
            return fallbackInstallId
        }
        
        let newInstallId = UUID().uuidString
        
        if keychainHelper.saveInstallId(newInstallId) {
            userDefaults.removeObject(forKey: Self.fallbackInstallIdKey)
        } else {
            // 저장 실패 시에도 동일 ID를 fallback에 보관하여 반복 재생성을 막습니다.
            userDefaults.set(newInstallId, forKey: Self.fallbackInstallIdKey)
        }
        
        stateQueue.sync {
            cachedInstallId = newInstallId
        }
        
        return newInstallId
    }
    
    /// 앱 시작 또는 재진입 시 인증 가능한 세션을 보장합니다.
    /// access token이 만료 임박/만료라면 refresh를 우선 시도하고,
    /// refresh가 불가능하면 guest register로 새 세션을 발급받습니다.
    @discardableResult
    func prepareSessionIfNeeded() async -> Bool {
        if hasUsableAccessToken {
            return true
        }
        
        let task: Task<Bool, Never> = stateQueue.sync {
            if let sessionRecoveryTask {
                return sessionRecoveryTask
            }
            
            if let sessionPreparationTask {
                return sessionPreparationTask
            }
            
            let newTask = Task<Bool, Never> { [weak self] in
                guard let self else { return false }
                defer {
                    self.stateQueue.sync {
                        self.sessionPreparationTask = nil
                    }
                }
                return await self.performSessionPreparation()
            }
            sessionPreparationTask = newTask
            return newTask
        }
        
        return await task.value
    }
    
    /// 인증 요청이 401로 실패했을 때 세션 복구를 시도합니다.
    /// refresh 성공 시 원요청 재시도로 복구하고, refresh가 무효면 register로 재발급합니다.
    @discardableResult
    func recoverSessionAfterUnauthorizedResponse() async -> Bool {
        let task: Task<Bool, Never> = stateQueue.sync {
            if let sessionPreparationTask {
                return sessionPreparationTask
            }
            
            if let sessionRecoveryTask {
                return sessionRecoveryTask
            }
            
            let newTask = Task<Bool, Never> { [weak self] in
                guard let self else { return false }
                defer {
                    self.stateQueue.sync {
                        self.sessionRecoveryTask = nil
                    }
                }
                return await self.performUnauthorizedRecovery()
            }
            sessionRecoveryTask = newTask
            return newTask
        }
        
        return await task.value
    }
    
    private var hasUsableAccessToken: Bool {
        stateQueue.sync {
            guard normalized(cachedAccessToken) != nil else {
                return false
            }
            return !shouldRefreshAccessTokenLocked(referenceDate: Date())
        }
    }
    
    private func performSessionPreparation() async -> Bool {
        if hasUsableAccessToken {
            return true
        }
        
        switch await refreshSessionIfPossible(rawResponseLogLabel: "Guest refresh") {
        case .success:
            return true
        case .needsRegistration:
            return await performGuestRegistration(rawResponseLogLabel: "Guest register")
        case .unavailable:
            return false
        }
    }
    
    private func performUnauthorizedRecovery() async -> Bool {
        switch await refreshSessionIfPossible(rawResponseLogLabel: "Guest refresh (401 recovery)") {
        case .success:
            return true
        case .needsRegistration:
            return await performGuestRegistration(rawResponseLogLabel: "Guest register (401 recovery)")
        case .unavailable:
            return false
        }
    }
    
    private func performGuestRegistration(rawResponseLogLabel: String) async -> Bool {
        let body = RegisterGuestRequest(installId: installId)
        
        do {
            let data: RegisterGuestData = try await DefaultNetworkService.shared.request(
                GuestRouter.register(body: body),
                rawResponseLogLabel: rawResponseLogLabel
            )
            
            return persistSession(tokens: data.tokens, fallbackUserId: data.userId)
        } catch {
            return false
        }
    }
    
    private func refreshSessionIfPossible(rawResponseLogLabel: String) async -> SessionRefreshResult {
        guard let refreshToken = normalized(refreshToken) else {
            return .needsRegistration
        }
        
        do {
            let data: RefreshGuestData = try await DefaultNetworkService.shared.request(
                GuestRouter.refresh(body: RefreshGuestSessionRequest(refreshToken: refreshToken)),
                rawResponseLogLabel: rawResponseLogLabel
            )
            
            guard persistSession(tokens: data.tokens, fallbackUserId: data.tokens.userId) else {
                return .unavailable
            }
            
            return .success
        } catch let error as NetworkError {
            if isRefreshTokenInvalid(error) {
                clearSession(preserveInstallId: true)
                return .needsRegistration
            }
            
            return .unavailable
        } catch {
            return .unavailable
        }
    }

    private func isRefreshTokenInvalid(_ error: NetworkError) -> Bool {
        switch error {
        case .unauthorized:
            return true
        case .server(let message, _):
            return isExpiredOrInvalidTokenMessage(message)
        default:
            return false
        }
    }

    private func isExpiredOrInvalidTokenMessage(_ message: String) -> Bool {
        let normalizedMessage = message
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedMessage.isEmpty else {
            return false
        }

        let invalidTokenPhrases = [
            "token is invalid or expired",
            "refresh token is invalid or expired",
            "invalid refresh token",
            "expired refresh token",
            "refresh token expired",
            "세션이 만료",
            "토큰이 만료",
            "토큰이 유효하지"
        ]

        return invalidTokenPhrases.contains { normalizedMessage.contains($0) }
    }
    
    /// 식별자 정보를 초기화합니다 (디버깅용)
    func resetIdentifiers() {
        clearSession(preserveInstallId: false)
    }
    
    func deleteCurrentAccount() async throws {
        try await DefaultNetworkService.shared.requestWithoutResponse(GuestRouter.deleteAccount)
        resetIdentifiers()
        TutorialManager.resetTutorial()
        NotificationCenter.default.post(name: .didRequestAppRelaunch, object: nil)
    }
    
    private func migrateFallbackToKeychainIfNeeded() {
        if let fallbackInstallId = normalized(
            userDefaults.string(forKey: Self.fallbackInstallIdKey)
        ), keychainHelper.saveInstallId(fallbackInstallId) {
            userDefaults.removeObject(forKey: Self.fallbackInstallIdKey)
        }
    }
    
    private func clearSession(preserveInstallId: Bool) {
        if preserveInstallId {
            _ = keychainHelper.deleteAccessToken()
            _ = keychainHelper.deleteRefreshToken()
        } else {
            _ = keychainHelper.deleteAllIdentifiers()
            userDefaults.removeObject(forKey: Self.fallbackInstallIdKey)
        }
        
        clearSessionMetadata()
        PushTokenStore.shared.clearRegistration()
        Task { @MainActor in
            PushNotificationSettingsStore.shared.reset()
        }
        
        stateQueue.sync {
            if !preserveInstallId {
                cachedInstallId = nil
            }
            cachedAccessToken = nil
            cachedRefreshToken = nil
            cachedSessionMetadata = nil
            sessionPreparationTask = nil
            sessionRecoveryTask = nil
        }
    }
    
    private func normalized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
    
    private func persistSession(tokens: GuestAuthTokens, fallbackUserId: String?) -> Bool {
        guard let accessToken = normalized(tokens.accessToken) else {
            return false
        }
        
        let persistedUserId = normalized(tokens.userId)
            ?? normalized(fallbackUserId)
            ?? stateQueue.sync { normalized(cachedSessionMetadata?.userId) }
        let persistedRefreshToken = normalized(tokens.refreshToken) ?? normalized(refreshToken)
        guard let refreshToken = persistedRefreshToken else {
            return false
        }
        
        let tokenType = normalized(tokens.tokenType)
            ?? stateQueue.sync { normalized(cachedSessionMetadata?.tokenType) }
            ?? "Bearer"
        let expiresAt = resolveAccessTokenExpiry(accessToken: accessToken, expiresIn: tokens.expiresIn)
        let metadata = SessionMetadata(
            userId: persistedUserId,
            tokenType: tokenType,
            accessTokenExpiresAt: expiresAt
        )
        
        if !keychainHelper.saveAccessToken(accessToken) {
            return false
        }
        
        if !keychainHelper.saveRefreshToken(refreshToken) {
            return false
        }
        
        guard saveSessionMetadata(metadata) else {
            return false
        }
        
        stateQueue.sync {
            cachedAccessToken = accessToken
            cachedRefreshToken = refreshToken
            cachedSessionMetadata = metadata
        }
        
        PushTokenStore.shared.clearRegistration()
        return true
    }
    
    private func shouldRefreshAccessTokenLocked(referenceDate: Date) -> Bool {
        guard normalized(cachedAccessToken) != nil else {
            return true
        }
        
        guard let metadata = cachedSessionMetadata else {
            return true
        }
        
        return metadata.accessTokenExpiresAt <= referenceDate.addingTimeInterval(Self.accessTokenRefreshLeeway)
    }
    
    private func loadSessionMetadata() -> SessionMetadata? {
        guard let data = userDefaults.data(forKey: Self.sessionMetadataKey) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(SessionMetadata.self, from: data)
        } catch {
            userDefaults.removeObject(forKey: Self.sessionMetadataKey)
            return nil
        }
    }
    
    private func saveSessionMetadata(_ metadata: SessionMetadata) -> Bool {
        do {
            let data = try JSONEncoder().encode(metadata)
            userDefaults.set(data, forKey: Self.sessionMetadataKey)
            return true
        } catch {
            return false
        }
    }
    
    private func clearSessionMetadata() {
        userDefaults.removeObject(forKey: Self.sessionMetadataKey)
    }
    
    private func deriveSessionMetadataFromStoredAccessToken(_ accessToken: String?) -> SessionMetadata? {
        guard let accessToken = normalized(accessToken),
              let expirationDate = jwtExpirationDate(from: accessToken) else {
            return nil
        }
        
        return SessionMetadata(
            userId: nil,
            tokenType: "Bearer",
            accessTokenExpiresAt: expirationDate
        )
    }
    
    private func resolveAccessTokenExpiry(accessToken: String, expiresIn: Int?) -> Date {
        if let expiresIn {
            return Date().addingTimeInterval(max(TimeInterval(expiresIn), 0))
        }
        
        if let expirationDate = jwtExpirationDate(from: accessToken) {
            return expirationDate
        }
        
        return Date().addingTimeInterval(Self.defaultAccessTokenLifetime)
    }
    
    private func jwtExpirationDate(from token: String) -> Date? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2,
              let payloadData = decodeBase64URL(String(segments[1])),
              let jsonObject = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = jsonObject["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
    }
    
    private func decodeBase64URL(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let remainder = base64.count % 4
        if remainder != 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        return Data(base64Encoded: base64)
    }
}
