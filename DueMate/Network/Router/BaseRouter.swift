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
    var queryItems: [URLQueryItem] { get }
    var requiresAuthorization: Bool { get }
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
    
    var requiresAuthorization: Bool {
        true
    }

    var queryItems: [URLQueryItem] {
        []
    }
    
    
    func asURLRequest() throws -> URLRequest {
        let config = configuration

        let baseURL = baseURL.appendingPathComponent(path)
        let resolvedURL: URL

        if queryItems.isEmpty {
            resolvedURL = baseURL
        } else {
            guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
                throw AFError.invalidURL(url: baseURL)
            }
            components.queryItems = queryItems
            guard let url = components.url else {
                throw AFError.invalidURL(url: baseURL)
            }
            resolvedURL = url
        }

        var request = URLRequest(url: resolvedURL)
        request.method = method
        
        // 기본 헤더 설정
        config.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 인증 헤더 추가
        if requiresAuthorization {
            config.authorizationHeaderProvider().forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Body 설정
        if let body = body {
            return try JSONParameterEncoder.default.encode(body, into: request)
        }
        
        return request
    }
    
    
}
