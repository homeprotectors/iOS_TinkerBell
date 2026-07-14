//
//  KeychainHelper.swift
//  DueMate
//
//  Created by Kacey Kim on 12/XX/25.
//

import Foundation
import Security

/// Keychain을 사용하여 데이터를 안전하게 저장하고 불러오는 헬퍼 클래스
/// kSecClassGenericPassword를 사용하여 암호화된 형태로 저장합니다.
final class KeychainHelper {
    
    // Keychain 서비스 식별자 (앱별 고유 값)
    private static let service = "com.duemate.app"
    
    // Keychain 키 이름
    private static let installIdKey = "installId"
    private static let accessTokenKey = "accessToken"
    private static let refreshTokenKey = "refreshToken"
    private static let legacyUserIdentifierKey = "userIdentifierUUID"
    
    /// installId를 Keychain에 저장합니다.
    /// - Parameter installId: 저장할 installId 문자열
    /// - Returns: 저장 성공 여부
    static func saveInstallId(_ installId: String) -> Bool {
        save(installId, account: installIdKey)
    }
    
    /// Keychain에서 installId를 불러옵니다.
    /// - Returns: 저장된 installId 문자열, 없으면 nil
    static func loadInstallId() -> String? {
        if let installId = load(account: installIdKey) {
            return installId
        }
        
        // Legacy key migration: 기존 userIdentifierUUID를 installId로 승격
        if let legacyValue = load(account: legacyUserIdentifierKey) {
            _ = saveInstallId(legacyValue)
            _ = delete(account: legacyUserIdentifierKey)
            return legacyValue
        }
        
        return nil
    }
    
    /// Keychain에서 installId를 삭제합니다.
    /// - Returns: 삭제 성공 여부
    static func deleteInstallId() -> Bool {
        delete(account: installIdKey)
    }
    
    /// Keychain에 installId가 저장되어 있는지 확인합니다.
    /// - Returns: 저장 여부
    static func hasInstallId() -> Bool {
        loadInstallId() != nil
    }
    
    /// accessToken을 Keychain에 저장합니다.
    /// - Parameter accessToken: 저장할 accessToken 문자열
    /// - Returns: 저장 성공 여부
    static func saveAccessToken(_ accessToken: String) -> Bool {
        save(accessToken, account: accessTokenKey)
    }
    
    /// Keychain에서 accessToken을 불러옵니다.
    /// - Returns: 저장된 accessToken 문자열, 없으면 nil
    static func loadAccessToken() -> String? {
        load(account: accessTokenKey)
    }
    
    /// Keychain에서 accessToken을 삭제합니다.
    /// - Returns: 삭제 성공 여부
    static func deleteAccessToken() -> Bool {
        delete(account: accessTokenKey)
    }
    
    /// Keychain에 accessToken이 저장되어 있는지 확인합니다.
    /// - Returns: 저장 여부
    static func hasAccessToken() -> Bool {
        loadAccessToken() != nil
    }
    
    /// refreshToken을 Keychain에 저장합니다.
    /// - Parameter refreshToken: 저장할 refreshToken 문자열
    /// - Returns: 저장 성공 여부
    static func saveRefreshToken(_ refreshToken: String) -> Bool {
        save(refreshToken, account: refreshTokenKey)
    }
    
    /// Keychain에서 refreshToken을 불러옵니다.
    /// - Returns: 저장된 refreshToken 문자열, 없으면 nil
    static func loadRefreshToken() -> String? {
        load(account: refreshTokenKey)
    }
    
    /// Keychain에서 refreshToken을 삭제합니다.
    /// - Returns: 삭제 성공 여부
    static func deleteRefreshToken() -> Bool {
        delete(account: refreshTokenKey)
    }
    
    /// Keychain에 refreshToken이 저장되어 있는지 확인합니다.
    /// - Returns: 저장 여부
    static func hasRefreshToken() -> Bool {
        loadRefreshToken() != nil
    }
    
    /// 식별자 정보를 모두 삭제합니다.
    @discardableResult
    static func deleteAllIdentifiers() -> Bool {
        let installDeleted = deleteInstallId()
        let accessTokenDeleted = deleteAccessToken()
        let refreshTokenDeleted = deleteRefreshToken()
        let legacyDeleted = delete(account: legacyUserIdentifierKey)
        return installDeleted && accessTokenDeleted && refreshTokenDeleted && legacyDeleted
    }
    
    // MARK: - Private
    
    private static func save(_ value: String, account: String) -> Bool {
        _ = delete(account: account)
        
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        }
        
        return false
    }
    
    private static func load(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data,
               let value = String(data: data, encoding: .utf8) {
                return value
            }
            return nil
        }
        
        if status == errSecItemNotFound {
            return nil
        }
        
        return nil
    }
    
    private static func delete(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        }
        
        return false
    }
}
