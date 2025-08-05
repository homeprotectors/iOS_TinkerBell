//
//  DeleteButton.swift
//  DueMate
//
//  Created by Kacey Kim on 7/31/25.
//

import SwiftUI

struct DeleteButton: View {
    @Binding var showAlert: Bool
    let action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: {
            showAlert = true
        }) {
            Image(systemName: "trash")
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .alert("이 항목을 삭제할까요?", isPresented: $showAlert) {
            Button("삭제", role: .destructive) {
                action()
            }
            Button("취소", role: .cancel) {}
        }
    }
}
