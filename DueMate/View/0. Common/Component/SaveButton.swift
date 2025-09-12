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
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
            }
            .frame(width: 70, height: 36)
            .background(isEnabled ? Color.accentColor : .gray)
            .cornerRadius(5)
            .disabled(!isEnabled)
        }
        
    }
}

