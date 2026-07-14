//
//  NetworkConfiguration.swift
//  DueMate
//
//  Created by Kacey Kim on 11/8/25.
//

import Foundation

struct NetworkConfiguration {
    // Base URL
    let baseURL: URL
    
    // 타임아웃 설정
    let requestTimeout: TimeInterval  // 요청 타임아웃
    let resourceTimeout: TimeInterval // 리소스 타임아웃
    
    // 인증 헤더 제공자 (클로저로 동적으로 access token 가져오기)
    let authorizationHeaderProvider: () -> [String: String]
    
    // 기본 헤더
    let defaultHeaders: [String: String]
    
    // 기본 설정
    static var `default`: NetworkConfiguration {
        NetworkConfiguration(
            baseURL: LocalConfiguration.apiBaseURL,
            requestTimeout: 30.0,
            resourceTimeout: 60.0,
            authorizationHeaderProvider: {
                guard let authorizationValue = UserIdentifierManager.shared.authorizationHeaderValue else {
                    return [:]
                }
                return ["Authorization": authorizationValue]
            },
            defaultHeaders: [
                "Content-Type": "application/json"
            ]
        )
    }
}
