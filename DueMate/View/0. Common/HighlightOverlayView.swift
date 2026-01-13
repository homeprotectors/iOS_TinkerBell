//
//  HighlightOverlayView.swift
//  DueMate
//
//  Created by Kacey Kim on 12/3/25.
//

import SwiftUI

struct HighlightOverlayView: View {

    let message: String
    let onDismiss: () -> Void

    
    private let overlayColor = Color.white.opacity(0.9)
    
    private let bubbleCornerRadius: CGFloat = 12
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                overlayColor
                    .ignoresSafeArea()
                messageBubble
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.4
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onDismiss()
            }
        }
    }
    
    private var messageBubble: some View {
        VStack {
            Text(message)
                .font(.buttonLight)
                .foregroundColor(Color.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4) // 줄간격 조정 (원하는 값으로 변경 가능)
                .frame(maxWidth: 280)
                .padding(30)
            
            Button(action: {
                onDismiss()
            }) {
                Text("확인")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 42)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    
            }
        }
        
        
    }
    
    
}

#Preview {
    HighlightOverlayView(
        message: "예시로 한가지 집안일을 미리 등록해 두었어요!\n자유롭게 수정해서 집안일 주기를 관리해보세요",
        onDismiss: {}
    )
}

