//
//  TitleTextField.swift
//  DueMate
//
//  Created by Kacey Kim on 7/15/25.
//

import SwiftUI

struct TitleTextField: View {
    @Binding var title: String
    
    var body: some View {
        HStack(spacing: 8) {
                    TextField("", text: $title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .textFieldStyle(.plain)
                        .fixedSize()
                    
                    Image(systemName: "pencil")
                        .font(.system(size: 30))
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
                
    }
}

#Preview {
    TitleTextField(title: .constant("휴지"))
}
