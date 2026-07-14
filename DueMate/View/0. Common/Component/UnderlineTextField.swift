//
//  UnderlineTextField.swift
//  DueMate
//
//  Created by Kacey Kim on 7/11/25.
//

import SwiftUI

struct UnderlineTextField: View {
    @Binding var text: String
    var placeholder: String = "Place holder"
    var keyboardType: UIKeyboardType = .default
    var onTextChange: ((String) -> Void)? = nil
    var foregroundColor: Color = Color.primaryText
    var fontSize: CGFloat = 16
    var fontWeight: Font.Weight = .medium
    var suffix: String? = nil
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0){
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.listTitleMedium)
                    
                    .foregroundColor(foregroundColor)
                    .background(Color.clear)
                    .onChange(of: text) {
                        onTextChange?(text)
                    }
                if let suffix = suffix {
                    Text(suffix)
                        .font(.listTitleMedium)
                }
            }
                
        }
    }
}

#Preview {
    UnderlineTextField(text: .constant(""), placeholder: "에베베", suffix: "개")
}
