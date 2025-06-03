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
    
    func handle(_ error: CustomError) {
        
        if let originalError = error.originalError {
            print("🚩 \(error)")
            print("🚩🚩Original Error: \(originalError.localizedDescription)")
        }
        
        
        
        currentError = error
        showToast = true
    }
}
