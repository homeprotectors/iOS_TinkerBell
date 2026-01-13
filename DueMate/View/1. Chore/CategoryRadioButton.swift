//
//  CategoryRadioButton.swift
//  DueMate
//
//  Created by Kacey Kim on 9/30/25.
//

import SwiftUI

struct CategoryRadioButton: View {
    let option: RadioOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                Image(isSelected ? option.onImage : option.offImage)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(option.title)
                    .font(.buttonText)
                    .foregroundColor(.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 3)
            .background(isSelected ? Color.buttonBackground : .white)
            .cornerRadius(4)
        }
    }
}

#Preview {
    CategoryRadioButton(option: RadioOption(title: "거실", value: "living", onImage: "ic_living", offImage: "ic_living_off"), isSelected: false, onTap: {})
}
