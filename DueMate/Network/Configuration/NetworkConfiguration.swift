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
    
    // 인증 헤더 제공자 (클로저로 동적으로 토큰 가져오기)
    // TODO: 서버에서 인증 구현 후 주석 해제
    // let authHeaderProvider: () -> [String: String]?
    
    // 기본 헤더
    let defaultHeaders: [String: String]
    
    // 기본 설정
    static var `default`: NetworkConfiguration {
        NetworkConfiguration(
            baseURL: URL(string: "http://ec2-15-164-220-42.ap-northeast-2.compute.amazonaws.com:8080/api")!,
            requestTimeout: 30.0,
            resourceTimeout: 60.0,
            // TODO: 서버에서 인증 구현 후 주석 해제
            // authHeaderProvider: {
            //     // UserDefaults나 Keychain에서 토큰 가져오기
            //     if let token = UserDefaults.standard.string(forKey: "authToken") {
            //         return ["Authorization": "Bearer \(token)"]
            //     }
            //     return nil
            // },
            defaultHeaders: [
                "Content-Type": "application/json"
            ]
        )
    }
}
