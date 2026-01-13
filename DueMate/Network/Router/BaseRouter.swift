//
//  Router.swift
//  DueMate
//
//  Created by Kacey Kim on 5/5/25.
//

import Alamofire
import Foundation

protocol BaseRouter: URLRequestConvertible {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
}


extension BaseRouter {
    
    // Configuration 접근 (전역 설정 사용)
    var configuration: NetworkConfiguration {
        NetworkConfiguration.default
    }
    
    // baseURL은 configuration에서 가져오기
    var baseURL: URL {
        configuration.baseURL
    }
    
    
    func asURLRequest() throws -> URLRequest {
        let config = configuration
        
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.method = method
        
        // 기본 헤더 설정
        config.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // TODO: 서버에서 인증 구현 후 주석 해제
        // 인증 헤더 추가 (토큰이 있으면)
        // if let authHeaders = config.authHeaderProvider() {
        //     authHeaders.forEach { key, value in
        //         request.setValue(value, forHTTPHeaderField: key)
        //     }
        // }
        
        // Body 설정
        if let body = body {
            return try JSONParameterEncoder.default.encode(body, into: request)
        }
        
        return request
    }
    
    
}

