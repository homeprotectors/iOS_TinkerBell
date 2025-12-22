//
//  TutorialView.swift
//  DueMate
//
//  Created by Kacey Kim on 11/21/25.
//

//
//  TutorialView.swift
//  DueMate
//
//  Created by Kacey Kim on 11/21/25.
//

import SwiftUI
import UIKit

// MARK: - TutorialStep
enum TutorialStep: Int, CaseIterable {
    case welcome
    case mainScreenInfo
    case showArrow
    case swipeInstruction
    case completionMessage
    case finalMessage
    case redirect
    
    var message: String? {
        switch self {
        case .welcome:
            return "Dueit에 오신걸 환영합니다!"
        case .mainScreenInfo:
            return "메인 화면에서는 해야하는 일들을\n급한 순으로 볼 수 있어요"
        case .showArrow:
            return "Dueit 설치하기를 완료했으니 꾹 눌러주세요!"
        case .swipeInstruction:
            return "위나 아래로 스와이프해서 완료처리 해볼까요?"
        case .completionMessage:
            return "완료되었습니다!\n완료된 아이템은 다음 주기가 다가오면 홈 화면에 나타납니다."
        case .finalMessage:
            return "이제 바로 Dueit을 쓰러 가볼까요?"
        case .redirect:
            return nil
        }
    }
}


enum TutorialAnimation {
    static let fadeIn: Double = 0.5
    static let step: Double = 0.4
    static let highlight: Double = 0.5
    static let springResponse: Double = 0.4
    static let springDamping: Double = 0.7
}

struct TutorialView: View {
    @StateObject private var viewModel = TutorialViewModel()
    @State private var currentStep: TutorialStep = .welcome
    @State private var showText = false
    @State private var isHighlighted = false
    
    var body: some View {
        ZStack {
            mainContent
                .blur(radius: viewModel.selectedItem == nil ? 0 : 10)
            
            if let item = viewModel.selectedItem {
                focusOverlay(for: item)
            }
            
            if currentStep != .redirect {
                tutorialOverlay
            }
        }
        .onAppear { showTutorialText() }
        .onChange(of: currentStep) { handleStepChange() }
    }
}

// MARK: - Main Content
private extension TutorialView {
    var mainContent: some View {
        VStack(alignment: .leading) {
            header
            
            if currentStep != .welcome {
                tutorialListView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    var header: some View {
        HStack {
            Image("logo")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.vertical, 20)
            Spacer()
        }
    }
}

// MARK: - Tutorial Overlay (텍스트 + 버튼 담당)
private extension TutorialView {
    var tutorialOverlay: some View {
        ZStack {
            if showText, let message = currentStep.message {
                VStack {
                    Text(message)
                        .font(.system(size: 18, weight: .medium))
                        .multilineTextAlignment(.center)
                    
                    if currentStep == .finalMessage {
                        startButton
                            .transition(.opacity)
                            .padding(.top, 16)
                    }
                }
                .padding(24)
                .frame(width: 350)
                .id(currentStep)
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { handleOverlayTap() }
    }
    
    var startButton: some View {
        Button(action: { TutorialManager.completeTutorial() }) {
            Text("시작하기")
                .font(.buttonText)
                .foregroundColor(.white)
                .frame(width: 120)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .cornerRadius(8)
        }
    }
}

// MARK: - Tutorial List
private extension TutorialView {
    var tutorialListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if currentStep.rawValue < TutorialStep.completionMessage.rawValue {
                HomeItemView(item: viewModel.firstItem, onLongPress: { frame in
                    if currentStep == .showArrow {
                        viewModel.selectItem(viewModel.firstItem, frame: frame)
                        moveStep()
                    }
                })
                .scaleEffect(isHighlighted ? 1.04 : 1.0)
                .formLabel("이번주 할 일")
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale),
                    removal: .opacity.combined(with: .scale(scale: 0.1))
                ))
            }
        }
    }
}

// MARK: - Focus Overlay
private extension TutorialView {
    func focusOverlay(for item: HomeItem) -> some View {
        ZStack {
            Color.black.opacity(0.1).ignoresSafeArea()
            
            TutorialFocusView(
                item: item,
                dragOffset: viewModel.dragOffset,
                onDragChanged: { viewModel.dragOffset = $0 },
                onDragEnded: { translation in
                    if abs(translation.height) > 50 {
                        viewModel.clearSelectedItem()
                        moveStep()
                    }
                }
            )
            .shadow(radius: 5)
            .position(
                x: viewModel.selectedItemFrame.midX,
                y: viewModel.selectedItemFrame.midY - 60
            )
        }
    }
}

// MARK: - Step Handling
private extension TutorialView {
    func showTutorialText() {
        withAnimation(.easeInOut(duration: TutorialAnimation.fadeIn)) {
            showText = true
        }
    }
    
    func moveStep() {
        guard let next = TutorialStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: TutorialAnimation.step)) {
            currentStep = next
        }
    }
    
    func handleStepChange() {
        if currentStep == .showArrow {
            startHighlightAnimation()
        } else {
            isHighlighted = false
        }
    }
    
    func startHighlightAnimation() {
        isHighlighted = false
        withAnimation(
            .easeInOut(duration: TutorialAnimation.highlight)
                .repeatForever(autoreverses: true)
        ) {
            isHighlighted = true
        }
    }
    
    func handleOverlayTap() {
        switch currentStep {
        case .welcome, .mainScreenInfo, .completionMessage:
            moveStep()
        default:
            break
        }
    }
}



// MARK: - Focus View
struct TutorialFocusView: View {
    let item: HomeItem
    let dragOffset: CGSize
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: (CGSize) -> Void
    
    var body: some View {
        HomeItemView(item: item)
            .padding()
            .offset(y: dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { onDragChanged($0.translation) }
                    .onEnded { onDragEnded($0.translation) }
            )
    }
}

#Preview {
    TutorialView()
}

