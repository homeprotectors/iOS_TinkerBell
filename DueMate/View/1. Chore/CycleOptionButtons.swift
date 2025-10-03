//
//  CycleOptionButtons.swift
//  DueMate
//
//  Created by Kacey Kim on 10/1/25.
//

import SwiftUI

struct CycleOptionRadioButtons: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.buttonText)
                .frame(maxWidth: .infinity)
                .padding(.vertical,10)
                .foregroundColor(Color.primaryText)
                .background( isSelected ? Color.backgroundBlue : .white)
                .cornerRadius(4)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.dotBlue, lineWidth: isSelected ? 0 : 0.5)
            
        )
    }
}

#Preview {
    CycleOptionRadioButtons(title: "요일", isSelected: true, onTap: {})
}
