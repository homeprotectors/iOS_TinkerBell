//
//  CustomToggleStyle.swift
//  DueMate
//
//  Created by Kacey Kim on 10/1/25.
//

import Foundation
import SwiftUI

struct SquareToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .font(.formlabel)
            Rectangle()
                .foregroundColor(configuration.isOn ? Color.accentColor : Color.shadeGray)
                .frame(width: 44, height: 28, alignment: .center)
                .overlay(
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .cornerRadius(4)
                        .offset(x: configuration.isOn ? 8 : -8, y: 0)
                )
                .cornerRadius(5)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
        }
        
    }
    
    
}

struct wrapper: View {
    @State var isOn = false
    
    var body: some View {
        Toggle(isOn: $isOn, label: {Text("고정 일정")})
            .toggleStyle(SquareToggleStyle())
    }
}

#Preview {
    wrapper()
}
