//
//  HighlightOverlayView.swift
//  DueMate
//
//  Created by Kacey Kim on 12/3/25.
//

import SwiftUI

enum BubblePosition {
    case top
    case bottom
    case center
}

struct HighlightOverlayView: View {
    var highlightFrame: CGRect? = nil
    let message: String
    var bubblePosition: BubblePosition = .center
    let onDismiss: () -> Void

    
    private let overlayColor = Color.white.opacity(0.9)
    
    private let bubbleCornerRadius: CGFloat = 12
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                overlayColor
                    .ignoresSafeArea()
                
                // 하이라이트 영역이 있으면 해당 영역을 제외한 오버레이
                if let frame = highlightFrame {
                    overlayWithHighlight(frame: frame, geometry: geometry)
                } else {
                    overlayColor
                        .ignoresSafeArea()
                }
                
                messageBubble
                    .position(
                        x: geometry.size.width / 2,
                        y: bubbleYPosition(in: geometry)
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onDismiss()
            }
        }
    }
    
    private func bubbleYPosition(in geometry: GeometryProxy) -> CGFloat {
        switch bubblePosition {
        case .top:
            return geometry.size.height * 0.25
        case .bottom:
            if let frame = highlightFrame {
                return frame.maxY + 100
            }
            return geometry.size.height * 0.75
        case .center:
            return geometry.size.height * 0.4
        }
    }
    
    @ViewBuilder
    private func overlayWithHighlight(frame: CGRect, geometry: GeometryProxy) -> some View {
        ZStack {
            overlayColor
                .ignoresSafeArea()
            
            // 하이라이트 영역을 투명하게 만들기
            Rectangle()
                .fill(Color.clear)
                .frame(width: frame.width + 20, height: frame.height + 20)
                .position(x: frame.midX, y: frame.midY)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
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

