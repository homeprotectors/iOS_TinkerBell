//
//  NetworkService.swift
//  DueMate
//
//  Created by Kacey Kim on 5/28/25.
//

import Foundation
import Alamofire

protocol NetworkService {
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T
    func requestWithoutResponse(_ router: BaseRouter) async throws
}

final class DefaultNetworkService: NetworkService {
    static let shared = DefaultNetworkService()
    private init() {}
    
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T {
        let response = try await AF.request(router)
            .validate()
            .serializingDecodable(Response<T>.self).value
        
        guard let data = response.data else {
            throw NetworkError.invalidData
        }
        
        return data
    }
    
    func requestWithoutResponse(_ router: any BaseRouter) async throws {
        let response = try await AF.request(router)
            .validate()
            .serializingDecodable(Response<EmptyResponse>.self).value
        
        guard response.success else {
            throw NetworkError.custom("에러가 발생했습니다. 다시 시도해 주세요")
        }
            
    }
    
    
    
}
