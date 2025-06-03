//
//  ValidationError.swift
//  DueMate
//
//  Created by Kacey Kim on 5/31/25.
//

import Foundation

enum ValidationError: CustomError {
    case requiredField
    case outOfRange365
    
    var toastMessage: String {
        switch self {
        case .requiredField: return "필요한 값을 전부 입력해주세요"
        case .outOfRange365: return "1과 365 사이의 숫자로 입력해주세요"
        }
    }
    
    var originalError: Error? {
        return nil
    }
}
