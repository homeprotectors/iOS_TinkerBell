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
    let isSave: Bool = false
    
    var body: some View {
        HStack {
            Button(action: action) {
                Text(isSave ? "Save" : "Add")
                    .font(.buttonText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(isEnabled ? Color.accentColor : .gray)
            }
            .frame(width: 70, height: 36)
            .padding(16)
            .disabled(!isEnabled)
        }
        
    }
}

#Preview {
    SaveButton(isEnabled: true, action: {})
}
