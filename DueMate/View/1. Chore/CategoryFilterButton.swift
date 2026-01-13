//
//  CategoryFilterButton.swift
//  DueMate
//
//  Created by Kacey Kim on 10/24/25.
//

import SwiftUI

struct CategoryFilterButton: View {
    let option: RadioOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(isSelected ? option.onImage : option.offImage)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(option.title)
                    .font(.smallButtonText)
                    .foregroundColor(.primaryText)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(isSelected ? Color.buttonBackground : .white)
            .cornerRadius(4)
        }
    }
}

#Preview {
    CategoryFilterButton(option: RadioOption(title: "거실", value: "living", onImage: "ic_living", offImage: "ic_living_off"), isSelected: true, onTap: {})
}
