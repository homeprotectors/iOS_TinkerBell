//
//  CustomLabelToggleStyle.swift
//  DueMate
//
//  Created by Kacey Kim on 11/5/25.
//

import SwiftUI

struct CustomLabelToggleStyle: ToggleStyle {
    var text1 = "변동금액"
    var text2 = "고정금액"
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text(configuration.isOn ? text1 : text2)
                .foregroundColor(.white)
                .font(.listSubitem)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .padding(configuration.isOn ? .leading : .trailing, 24)
                .background(configuration.isOn ? Color.accentColor : .black)
                .cornerRadius(5)
                .overlay(
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .cornerRadius(4)
                        .offset(x: configuration.isOn ? -30 : 30, y: 0)
                )
            
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                configuration.isOn.toggle()
            }
        }
    }
}

struct toggleWrapper: View {
    @State var isOn = false
    
    var body: some View {
        Toggle(isOn: $isOn, label: {Text("고정 일정")})
            .toggleStyle(CustomLabelToggleStyle())
    }
}

#Preview {
    toggleWrapper()
}
