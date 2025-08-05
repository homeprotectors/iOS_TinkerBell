//
//  SaveButton.swift
//  DueMate
//
//  Created by Kacey Kim on 7/24/25.
//

import SwiftUI

struct SaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("저장")
                .frame(maxWidth: .infinity)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 50)
                .padding(.vertical, 20)
                .background(isEnabled ? Color.overdue : .gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
    }
}

