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

private struct MessageOnlyErrorResponse: Decodable {
    let message: String?
    let error: String?
}

protocol NetworkService {
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T
    func requestOptional<T: Decodable>(_ router: BaseRouter) async throws -> T?
    func requestWithoutResponse(_ router: BaseRouter) async throws
}

final class DefaultNetworkService: NetworkService {
    static let shared = DefaultNetworkService()
    
    private let session: Session
    private let decoder: JSONDecoder
    
    private init(configuration: NetworkConfiguration = .default) {
        let urlConfiguration = URLSessionConfiguration.af.default
        urlConfiguration.timeoutIntervalForRequest = configuration.requestTimeout
        urlConfiguration.timeoutIntervalForResource = configuration.resourceTimeout
        urlConfiguration.waitsForConnectivity = true
        
        self.session = Session(configuration: urlConfiguration)
        self.decoder = JSONDecoder()
    }
    
    func request<T: Decodable>(_ router: BaseRouter) async throws -> T {
        try await request(
            router,
            rawResponseLogLabel: nil,
            allowAuthenticationRecovery: true
        )
    }
    
    func requestOptional<T: Decodable>(_ router: BaseRouter) async throws -> T? {
        try await requestOptional(
            router,
            rawResponseLogLabel: nil,
            allowAuthenticationRecovery: true
        )
    }
    
    func request<T: Decodable>(
        _ router: BaseRouter,
        rawResponseLogLabel: String
    ) async throws -> T {
        try await request(
            router,
            rawResponseLogLabel: rawResponseLogLabel,
            allowAuthenticationRecovery: true
        )
    }
    
    private func request<T: Decodable>(
        _ router: BaseRouter,
        rawResponseLogLabel: String?,
        allowAuthenticationRecovery: Bool
    ) async throws -> T {
        let (statusCode, responseData) = try await performDataRequest(
            router,
            rawResponseLogLabel: rawResponseLogLabel
        )
        
        if statusCode == 401,
           router.requiresAuthorization,
           allowAuthenticationRecovery,
           await UserIdentifierManager.shared.recoverSessionAfterUnauthorizedResponse() {
            return try await request(
                router,
                rawResponseLogLabel: rawResponseLogLabel,
                allowAuthenticationRecovery: false
            )
        }
        
        guard (200...299).contains(statusCode) else {
            throw networkError(statusCode: statusCode, responseData: responseData)
        }
        
        return try decodeSuccessData(responseData, as: T.self)
    }
    
    private func requestOptional<T: Decodable>(
        _ router: BaseRouter,
        rawResponseLogLabel: String?,
        allowAuthenticationRecovery: Bool
    ) async throws -> T? {
        let (statusCode, responseData) = try await performDataRequest(
            router,
            rawResponseLogLabel: rawResponseLogLabel
        )
        
        if statusCode == 401,
           router.requiresAuthorization,
           allowAuthenticationRecovery,
           await UserIdentifierManager.shared.recoverSessionAfterUnauthorizedResponse() {
            return try await requestOptional(
                router,
                rawResponseLogLabel: rawResponseLogLabel,
                allowAuthenticationRecovery: false
            )
        }
        
        guard (200...299).contains(statusCode) else {
            throw networkError(statusCode: statusCode, responseData: responseData)
        }
        
        return try decodeOptionalSuccessData(responseData, as: T.self)
    }
    
    /// 에러 응답 본문을 파싱하여 에러 메시지를 추출합니다.
    /// 재요청 없이 실패한 응답 본문을 직접 파싱합니다.
    private func parseErrorResponse(from data: Data, statusCode: Int) -> String? {
        guard !data.isEmpty else { return nil }
        
        // 500 에러 시 Spring Boot 에러 응답 구조체로 파싱 시도
        if statusCode >= 500,
           let springBootError = try? decoder.decode(SpringBootErrorResponse.self, from: data) {
                return springBootError.errorMessage
        }
        
        // 400 에러 또는 기타 에러 시 Response<EmptyData> 구조체로 파싱 시도
        if let errorResponse = try? decoder.decode(Response<EmptyData>.self, from: data) {
            return errorResponse.message
        }
        
        if let errorResponse = try? decoder.decode(MessageOnlyErrorResponse.self, from: data) {
            let message = (errorResponse.message ?? errorResponse.error ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !message.isEmpty {
                return message
            }
        }
        
        if let fallback = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !fallback.isEmpty {
            return fallback
        }
        
        return nil
    }
    
    func requestWithoutResponse(_ router: BaseRouter) async throws {
        try await requestWithoutResponse(router, allowAuthenticationRecovery: true)
    }
    
    private func requestWithoutResponse(
        _ router: BaseRouter,
        allowAuthenticationRecovery: Bool
    ) async throws {
        let (statusCode, responseData) = try await performDataRequest(router)
        
        if statusCode == 401,
           router.requiresAuthorization,
           allowAuthenticationRecovery,
           await UserIdentifierManager.shared.recoverSessionAfterUnauthorizedResponse() {
            try await requestWithoutResponse(router, allowAuthenticationRecovery: false)
            return
        }
        
        guard (200...299).contains(statusCode) else {
            throw networkError(statusCode: statusCode, responseData: responseData)
        }
        
        if !responseData.isEmpty,
           let response = try? decoder.decode(Response<EmptyData>.self, from: responseData),
           response.success == false {
            throw NetworkError.server(response.message)
        }
    }
    
    private func performDataRequest(
        _ router: BaseRouter,
        rawResponseLogLabel: String? = nil
    ) async throws -> (statusCode: Int, data: Data) {
        let dataResponse = await session.request(router)
            .serializingData()
            .response
        
        guard let httpResponse = dataResponse.response else {
            if let error = dataResponse.error {
                throw convertToNetworkError(error)
            }
            throw NetworkError.unknown(
                NSError(
                    domain: "NetworkService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP 응답이 없습니다."]
                )
            )
        }
        
        let statusCode = httpResponse.statusCode
        let responseData = dataResponse.data ?? Data()
        logRawResponseIfNeeded(responseData, statusCode: statusCode, label: rawResponseLogLabel)
        
        return (statusCode, responseData)
    }
    
    private func decodeSuccessData<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            let response = try decoder.decode(Response<T>.self, from: data)
            
            guard response.success else {
                throw NetworkError.server(response.message)
            }
            
            guard let decodedData = response.data else {
                throw NetworkError.data("No data received")
            }
            
            return decodedData
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.data("응답 데이터를 읽을 수 없습니다", original: error)
        }
    }
    
    private func decodeOptionalSuccessData<T: Decodable>(_ data: Data, as type: T.Type) throws -> T? {
        guard !data.isEmpty else { return nil }
        
        do {
            let response = try decoder.decode(Response<T>.self, from: data)
            
            guard response.success else {
                throw NetworkError.server(response.message)
            }
            
            return response.data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.data("응답 데이터를 읽을 수 없습니다", original: error)
        }
    }
    
    private func networkError(statusCode: Int, responseData: Data) -> NetworkError {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode))
        let errorMessage = parseErrorResponse(from: responseData, statusCode: statusCode)
        
        if statusCode == 401 {
            return .unauthorized(
                errorMessage ?? "Token is invalid or expired.",
                original: afError
            )
        }
        
        if let errorMessage {
            return .server(errorMessage, original: afError)
        }
        
        return convertToNetworkError(afError)
    }
    
    private func logRawResponseIfNeeded(_ data: Data, statusCode: Int, label: String?) {
        _ = data
        _ = statusCode
        _ = label
    }
    
    private func convertToNetworkError(_ error: Error) -> NetworkError {
        
        if let afError = error as? AFError {
            //status code error
            if case .responseValidationFailed(reason: .unacceptableStatusCode(let code)) = afError {
                if code == 401 {
                    return .unauthorized("Token is invalid or expired.", original: afError)
                }
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
                    return .timeout(original: error)
                default:
                    return .network(error.localizedDescription, original: error)
                }
            }
            
            if case .responseSerializationFailed = afError {
                return .data("data decoding Error",original: afError)
            }
            
            return .unknown(afError)
        }
        
        return .unknown(error)
        
    }
    
}
