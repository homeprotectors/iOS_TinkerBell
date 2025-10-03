//
//  MultiSelectButton.swift
//  DueMate
//
//  Created by Kacey Kim on 10/2/25.
//

import SwiftUI

struct MultiSelectButton<T: DetailCycleOption>: View {
    let option: T
    var onTap: () -> Void = {}
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            onTap()
        }) {
            Text(option.display)
                .font(.buttonText)
                .foregroundColor(Color.primaryText)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.backgroundBlue : Color.backgroundGray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor, lineWidth: isSelected ? 0.5 : 0)
                            )
                )
            
        }
    }
}

#Preview {
    MultiSelectButton(option: DayOptions.fri, isSelected: .constant(true))
}
