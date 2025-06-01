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
    @Published var currentError: NetworkError?
    @Published var showToast: Bool = false
    
    private init() {}
    
    func handle(_ error:NetworkError) {
        print("🚩Error handler: \n\(error)")
        currentError = error
        showToast = true
    }
}
