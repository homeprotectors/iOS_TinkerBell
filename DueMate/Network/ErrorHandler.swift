//
//  ErrorHandler.swift
//  DueMate
//
//  Created by Kacey Kim on 5/31/25.
//  >> show an error toast and print error log

import Foundation

@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    @Published var currentError: CustomError?
    @Published var showToast: Bool = false
    
    private init() {}
    
    /// CustomError를 처리하고 Toast로 표시합니다.
    /// - Parameter error: 처리할 에러 (CustomError 프로토콜을 준수)
    func handle(_ error: CustomError) {
        // 에러 로깅
        logError(error)
        
        // Toast 표시
        currentError = error
        showToast = true
    }
    
    /// 일반 Error를 처리합니다. CustomError로 변환 후 handle 호출
    /// - Parameter error: 처리할 에러
    func handle(_ error: Error) {
        if let customError = error as? CustomError {
            handle(customError)
        } else {
            handle(NetworkError.unknown(error))
        }
    }
    
    /// 에러를 로깅합니다.
    /// - Parameter error: 로깅할 에러
    private func logError(_ error: CustomError) {
        print("🚩 [ERROR] \(error.toastMessage)")
        
        // NetworkError의 경우 서버 메시지 등 상세 정보 로깅
        if let networkError = error as? NetworkError {
            switch networkError {
            case .server(let message, _) where !message.isEmpty:
                print("🚩 [SERVER MESSAGE] \(message)")
            case .network(let message, _):
                print("🚩 [NETWORK ERROR] \(message)")
            case .data(let message, _):
                print("🚩 [DATA ERROR] \(message)")
            case .timeout:
                print("🚩 [TIMEOUT ERROR] Request timeout")
            case .unknown(let err):
                print("🚩 [UNKNOWN ERROR] \(err.localizedDescription)")
            default:
                break
            }
        }
        
        // 원본 에러 로깅
        if let originalError = error.originalError {
            print("🚩 [ORIGINAL ERROR] \(originalError.localizedDescription)")
        }
    }
}
