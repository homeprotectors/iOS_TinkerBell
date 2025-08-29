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
    case unknown(Error)
    
    
    var toastMessage: String {
        switch self {
        case .network:
            return "네트워크 확인 후 다시 시도해주세요."
        case .server(let message, _):
            return message
        default:
            return "에러가 발생했습니다. 다시 시도해주세요."
        }
    }
    
    var originalError: Error? {
        switch self {
        case .network(_, let err): return err
        case .server(_, let err): return err
        case .data(_, let err): return err
        case .unknown(let err): return err
        }
    }
    
}
