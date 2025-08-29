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
    
    var errorMessage: String {
        return error
    }
}

protocol NetworkService {
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T
    func requestWithoutResponse(_ router: BaseRouter) async throws
}

final class DefaultNetworkService: NetworkService {
    static let shared = DefaultNetworkService()
    private init() {}
    
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T {
        do {
            print("🌐 NetworkService: 요청 시작")
            let response = try await AF.request(router)
                .serializingDecodable(Response<T>.self)
                .value
            
            print("✅ NetworkService: 응답 파싱 성공 - success: \(response.success)")
            
            guard response.success else {
                print("❌ NetworkService: 서버 에러 - \(response.message)")
                throw NetworkError.server(response.message)
            }
            
            guard let data = response.data else {
                print("❌ NetworkService: 데이터 없음")
                throw NetworkError.data("No data received")
            }
            
            print("✅ NetworkService: 데이터 반환 성공")
            return data
            
        } catch {
            print("🚨 NetworkService: 에러 발생 - \(error)")
            
            // HTTP 상태 코드 에러나 파싱 에러 시에도 Response<T>로 파싱 시도
            if let afError = error as? AFError {
                print("🔍 AFError 타입: \(afError)")
                
                switch afError {
                case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
                    print("📡 HTTP \(code) 에러 - 서버 응답 시도")
                    // 400, 500 등 HTTP 에러 시에도 서버 응답의 message를 읽기
                    do {
                        if code >= 500 {
                            // 500 에러 시 Spring Boot 에러 응답 구조체로 파싱
                            let errorResponse = try await AF.request(router)
                                .serializingDecodable(SpringBootErrorResponse.self)
                                .value
                            print("✅ Spring Boot 에러 응답 파싱 성공: \(errorResponse.errorMessage)")
                            throw NetworkError.server(errorResponse.errorMessage, original: afError)
                        } else {
                            // 400 에러 시 기존 Response<T> 구조체로 파싱
                            let errorResponse = try await AF.request(router)
                                .serializingDecodable(Response<EmptyData>.self)
                                .value
                            print("✅ 에러 응답 파싱 성공: \(errorResponse.message)")
                            throw NetworkError.server(errorResponse.message, original: afError)
                        }
                    } catch {
                        print("❌ 에러 응답 파싱 실패: \(error)")
                        // 에러 응답 파싱 실패 시 기본 메시지
                        if code >= 500 {
                            throw NetworkError.server("서버 오류가 발생했습니다 (HTTP \(code))", original: afError)
                        } else if code >= 400 {
                            throw NetworkError.server("요청이 잘못되었습니다 (HTTP \(code))", original: afError)
                        } else {
                            throw NetworkError.server("HTTP \(code) 에러", original: afError)
                        }
                    }
                    
                case .responseSerializationFailed:
                    print("📡 JSON 파싱 에러 - 서버 응답 시도")
                    // JSON 파싱 에러 시에도 서버 응답 시도
                    do {
                        let errorResponse = try await AF.request(router)
                            .serializingDecodable(Response<EmptyData>.self)
                            .value
                        print("✅ 에러 응답 파싱 성공: \(errorResponse.message)")
                        throw NetworkError.server(errorResponse.message, original: afError)
                    } catch {
                        print("❌ 에러 응답 파싱 실패: \(error)")
                        throw NetworkError.data("응답 데이터를 읽을 수 없습니다", original: afError)
                    }
                    
                default:
                    print("🔍 기타 AFError: \(afError)")
                    break
                }
            }
            
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
                // 500 에러 시 서버 응답의 message를 읽어오기
                if code >= 500 {
                    return .server("서버 오류가 발생했습니다 (HTTP \(code))", original: afError)
                } else if code >= 400 {
                    return .server("요청이 잘못되었습니다 (HTTP \(code))", original: afError)
                } else {
                    return .server("HTTP \(code) 에러", original: afError)
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



