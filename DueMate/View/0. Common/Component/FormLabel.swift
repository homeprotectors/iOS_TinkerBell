//
//  FormLabel.swift
//  DueMate
//
//  Created by Kacey Kim on 7/15/25.
//

import SwiftUI

struct FormLabel: ViewModifier {
    let label: String
    var color: Color = .black
    var size: CGFloat = 12
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
            
            content
        }
    }
}

extension View {
    func formLabel(_ label: String) -> some View {
        modifier(FormLabel(label: label))
    }
}
