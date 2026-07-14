//
//  LocalConfiguration.swift
//  DueMate
//
//  Created by Codex on 4/4/26.
//

import Foundation

enum LocalConfiguration {
    private static let apiBaseURLKey = "API_BASE_URL"
    private static let authRefreshPathKey = "AUTH_REFRESH_PATH"
    
    static var apiBaseURL: URL {
        guard let rawValue = value(forKey: apiBaseURLKey),
              let url = URL(string: rawValue) else {
            fatalError("LocalConfig.plist의 API_BASE_URL이 올바르지 않습니다.")
        }
        return url
    }
    
    static var authRefreshPath: String {
        let defaultPath = "/auth/refresh"
        guard let rawValue = value(forKey: authRefreshPathKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawValue.isEmpty else {
            return defaultPath
        }
        
        return rawValue.hasPrefix("/") ? rawValue : "/\(rawValue)"
    }
    
    private static func value(forKey key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "LocalConfig", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: url) as? [String: Any],
              let value = dictionary[key] as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        return value
    }
}
