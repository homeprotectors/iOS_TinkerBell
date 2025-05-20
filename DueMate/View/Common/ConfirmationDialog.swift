//
//  ConfirmationDialog.swift
//  DueMate
//
//  Created by Kacey Kim on 5/17/25.
//

import SwiftUI


enum DialogType {
    case mainViewCompletion
    case historyCompletion
    case historyCancelation
    
    var message: String {
        switch self {
        case .mainViewCompletion:
            return "오늘 할 일을 완료하셨나요?"
        case .historyCompletion:
            return "이 날짜에 완료 처리할까요?"
        case .historyCancelation:
            return "이 날짜의 기록을 지울까요?"
        }
    }
    
    var confirmText: String {
        switch self {
        case .historyCancelation:
            return "삭제"
        default:
            return "확인"
        }
    }
    
    var cancelText: String {
        return "취소"
    }
}


struct ConfirmationDialog: View {
    @Binding var isPresented: Bool
    let type: DialogType
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(type.message)
                .font(.headline)
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text(type.cancelText)
                        .frame(maxWidth: .infinity)
                }
                Button(action: {
                    onConfirm()
                    isPresented = false
                }){
                    Text(type.confirmText)
                        .frame(maxWidth: .infinity)
                }
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
    }
}

#Preview {
    ConfirmationDialog(isPresented: .constant(true), type: .historyCompletion, onConfirm: {})
}
