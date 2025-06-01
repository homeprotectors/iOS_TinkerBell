//
//  NetworkError.swift
//  DueMate
//
//  Created by Kacey Kim on 5/28/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case network(String)
    case server(String)
    case data(String)
    case custom(String)
  
    
    var toastMessage: String {
        switch self {
        case .network:
            return "네트워크 연결을 확인해주세요"
        default:
            return "에러가 발생했습니다. 다시 시도해주세요."
        }
    }
}
