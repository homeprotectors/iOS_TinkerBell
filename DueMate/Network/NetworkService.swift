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
        do {
            let response = try await AF.request(router)
                .validate()
                .serializingDecodable(Response<T>.self)
                .value
            
            guard response.success else {
                throw NetworkError.server(response.message)
            }
            
            guard let data = response.data else {
                throw NetworkError.data("No data received")
            }
            
            return data
            
        } catch {
            throw convertToNetworkError(error)
        }
    }
    
    func requestWithoutResponse(_ router: any BaseRouter) async throws {
        do {
            _ = try await AF.request(router)
                .validate()
                .serializingString()
                .value
        } catch {
            throw convertToNetworkError(error)
        }
    }
    
    private func convertToNetworkError(_ error: Error) -> NetworkError {
        
        if let afError = error as? AFError {
            //status code error
            if case .responseValidationFailed(reason: .unacceptableStatusCode(let code)) = afError {
                switch code {
                default :
                    return .server("statuse code: \(code)")
                }
            }
            
            // network related error
            if case .sessionTaskFailed(let error as URLError) = afError {
                switch error.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .network("internet connection issue")
                case .timedOut:
                    return .network("time out")
                default:
                    return .network(error.localizedDescription, original: error)
                }
            }
            
            if case .responseSerializationFailed(let reason) = afError {
                return .data("data decoding Error",original: afError)
            }
            
            return .unknown(afError)
        }
        
        return .unknown(error)
        
    }
    
}


