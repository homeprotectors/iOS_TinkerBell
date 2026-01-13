//
//  NetworkError.swift
//  DueMate
//
//  Created by Kacey Kim on 5/28/25.
//

import Foundation

protocol CustomError: LocalizedError {
    var toastMessage: String { get }
    var originalError: Error? { get }
}

enum NetworkError: CustomError {
    
    case network(String, original: Error? = nil)
    case server(String, original: Error? = nil)
    case data(String, original: Error? = nil)
    case timeout(original: Error? = nil)
    case unknown(Error)
    
    
    var toastMessage: String {
        switch self {
        case .network(let message, _):
            // 네트워크 연결 관련 에러 (타임아웃은 별도 케이스로 처리됨)
            if message.contains("internet connection") {
                return "인터넷 연결을 확인해주세요."
            } else {
                return "네트워크 연결이 불안정합니다.\n잠시 후 다시 시도해주세요."
            }
            
        case .server(let message, _):
            // 서버 메시지는 로그에만 출력하고, 사용자에게는 통일된 메시지 표시
            // 서버 메시지는 ErrorHandler에서 로깅됨
            return "서버 오류가 발생했습니다.\n잠시 후 다시 시도해주세요."
            
        case .data(let message, _):
            // 데이터 파싱 에러
            return "데이터를 불러올 수 없습니다.\n다시 시도해주세요."
            
        case .timeout:
            return "요청 시간이 초과되었습니다.\n다시 시도해주세요."
            
        case .unknown:
            return "오류가 발생했습니다.\n다시 시도해주세요."
        }
    }
    
    var originalError: Error? {
        switch self {
        case .network(_, let err): return err
        case .server(_, let err): return err
        case .data(_, let err): return err
        case .timeout(let err): return err
        case .unknown(let err): return err
        }
    }
    
}
