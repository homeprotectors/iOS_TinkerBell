//
//  QuantityOverlayView.swift
//  DueMate
//
//  Created by Kacey Kim on 7/22/25.
//

import SwiftUI

struct QuantityOverlayView: View {
    @Binding var isPresented: Bool
    @Binding var quantity: String
    let color: Color
    let onSave: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: geo.size.height * 1.5, height: geo.size.height * 1.5)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                VStack(spacing: 24) {
                    Text("현재 수량이 몇 개 남았나요?")
                        .foregroundColor(.white)
                        .font(.headline)
                    TextField("수량", text: $quantity)
                        .keyboardType(.numberPad)
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .frame(width: 120)
                    Button(action: {
                        onSave()
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Text("저장")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .foregroundColor(color)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .transition(.scale)
        .zIndex(1)
    }
}

#Preview {
    QuantityOverlayView(isPresented: .constant(true), quantity:.constant("11"), color: .overdue, onSave: {})
}
