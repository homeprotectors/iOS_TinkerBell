//
//  NetworkService.swift
//  DueMate
//
//  Created by Kacey Kim on 5/28/25.
//

import Foundation
import Alamofire

// 빈 데이터를 위한 구조체
struct EmptyData: Codable {}

// Spring Boot 에러 응답 구조체
struct SpringBootErrorResponse: Codable {
    let timestamp: String
    let status: Int
    let error: String
    let path: String
}

protocol NetworkService {
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T
    func requestWithoutResponse(_ router: BaseRouter) async throws
}

final class DefaultNetworkService: NetworkService {
    static let shared = DefaultNetworkService()
    private let configuration = NetworkConfiguration.default
    private lazy var session: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.requestTimeout
        config.timeoutIntervalForResource = configuration.resourceTimeout
        return Session(configuration: config)
    }()
    
    private init() {}
    
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T {
        let dataResponse = await session.request(router)
            .serializingData()
            .response
        
        // HTTP 응답이 있는 경우
        if let httpResponse = dataResponse.response,
           let responseData = dataResponse.data {
            
            let statusCode = httpResponse.statusCode
            
            // 성공 응답인 경우 (200-299)
            if (200...299).contains(statusCode) {
                do {
                    let response = try JSONDecoder().decode(Response<T>.self, from: responseData)
                    
                    guard response.success else {
                        throw NetworkError.server(response.message)
                    }
                    
                    guard let data = response.data else {
                        throw NetworkError.data("No data received")
                    }
                    
                    return data
                } catch {
                    if error is NetworkError {
                        throw error
                    }
                    throw NetworkError.data("응답 데이터를 읽을 수 없습니다", original: error)
                }
            } else {
                // 에러 응답인 경우
                let errorMessage = parseErrorResponse(from: responseData, statusCode: statusCode) ?? ""
                throw NetworkError.server(errorMessage, original: nil)
            }
        }
        
        // HTTP 응답이 없는 경우 (네트워크 에러 등)
        if let error = dataResponse.error {
            throw convertToNetworkError(error)
        }
        
        throw NetworkError.unknown(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
    }
    
   
    private func parseErrorResponse(from data: Data, statusCode: Int) -> String? {
        // 500 에러 시 Spring Boot 에러 응답 구조체로 파싱 시도
        if statusCode >= 500 {
            if let springBootError = try? JSONDecoder().decode(SpringBootErrorResponse.self, from: data) {
                return springBootError.error
            }
        }
        
        // 400 에러 또는 기타 에러 시 Response<EmptyData> 구조체로 파싱 시도
        if let errorResponse = try? JSONDecoder().decode(Response<EmptyData>.self, from: data) {
            return errorResponse.message
        }
        
        return nil
    }
    
    func requestWithoutResponse(_ router: any BaseRouter) async throws {
        do {
            _ = try await session.request(router)
                .validate()
                .serializingString()
                .value
        } catch {
            throw convertToNetworkError(error)
        }
    }
    
    private func convertToNetworkError(_ error: Error) -> NetworkError {
        guard let afError = error as? AFError else {
            return .unknown(error)
        }
        
        // 네트워크 연결 에러
        if case .sessionTaskFailed(let urlError as URLError) = afError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .network("internet connection issue", original: urlError)
            case .timedOut:
                return .timeout(original: urlError)
            default:
                return .network(urlError.localizedDescription, original: urlError)
            }
        }
        
        // 데이터 파싱 에러
        if case .responseSerializationFailed = afError {
            return .data("data decoding Error", original: afError)
        }
        
        return .unknown(afError)
    }
    
}



