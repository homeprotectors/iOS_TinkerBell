//
//  ErrorToastView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/30/25.
//

import Foundation
import SwiftUI

// toast view
struct ErrorToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(.gray.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}

// toast modifier
struct ErrorToastModifier: ViewModifier {
    @ObservedObject private var errorHandler = ErrorHandler.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if errorHandler.showToast {
                        VStack {
                            Spacer()
                            ErrorToastView(message: errorHandler.currentError?.toastMessage ?? "")
                                .padding(.bottom, 20)
                                .transition(.move(edge: .bottom))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            errorHandler.showToast = false
                                        }
                                    }
                                }
                        }
                    }
                }
                .animation(.spring(), value: errorHandler.showToast)
            )
    }
}

extension View {
    func withErrorToast() -> some View {
        modifier(ErrorToastModifier())
    }
}
