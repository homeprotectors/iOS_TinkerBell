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
        HStack {
            Spacer()
            Button(action: action) {
                Text("저장")
                    .frame(width: 70, height: 37)
                    .font(.system(size: 18, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(isEnabled ? Color.overdue : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    
            }
            .disabled(!isEnabled)
        }
        
    }
}

