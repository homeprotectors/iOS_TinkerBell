//
//  HomeNotificationSettingsSheetView.swift
//  DueMate
//
//  Created by Codex on 5/8/26.
//

import SwiftUI

struct HomeSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @ObservedObject private var pushNotificationSettings = PushNotificationSettingsStore.shared
    @State private var isDeleteAlertPresented = false
    @State private var isDeletingAccount = false
    
    // Fill this in when the policy page is ready.
    private let privacyPolicyURLString = "https://turquoise-pulsar-0e3.notion.site/3764e53559a580d98806f3c6a86bc415"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            toggleRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 22)
        .padding(.top, 30)
        .task {
            await pushNotificationSettings.loadIfNeeded()
        }
        .alert("전체 데이터를 삭제할까요?", isPresented: $isDeleteAlertPresented) {
            Button("삭제하기", role: .destructive) {
                deleteAccount()
            }
            
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 작업을 진행하면 현재 계정이 서버에서 완전히 삭제되고, 저장된 모든 사용자 정보와 집안일 데이터가 함께 사라집니다. 삭제 후에는 복구할 수 없으며, 앱은 새 계정으로 다시 시작됩니다.")
        }
    }
    
    private var headerView: some View {
        HStack {
            
            Spacer()
            Button("닫기") {
                dismiss()
            }
            .font(.listSubitem)
            .foregroundColor(.accentColor)
        }
        .padding(.bottom, 30)
    }
    
    private var toggleRow: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack{
                Text("푸시 알림 설정")
                    .font(.buttonLight)
                Spacer()
                Toggle(
                    "",
                    isOn: Binding(
                        get: { pushNotificationSettings.isNotificationEnabled },
                        set: { pushNotificationSettings.setNotificationEnabled($0) }
                    )
                )
                .toggleStyle(SquareToggleStyle())
                .disabled(
                    !pushNotificationSettings.isLoaded ||
                    pushNotificationSettings.isUpdating ||
                    isDeletingAccount
                )
            }
            
            Button {
                guard let url = URL(string: privacyPolicyURLString),
                      !privacyPolicyURLString.isEmpty else { return }
                openURL(url)
            } label: {
                HStack {
                    Text("개인정보처리방침")
                        .font(.buttonLight)
                        .foregroundColor(.primaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical,10)
            
            
            
            Spacer()
            
            Button("전체 데이터 지우기") {
                isDeleteAlertPresented = true
            }
            .buttonStyle(.plain)
            .font(.listSubitem)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(isDeletingAccount)
            .padding(.bottom, 20)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func deleteAccount() {
        guard !isDeletingAccount else { return }
        
        isDeletingAccount = true
        Task {
            do {
                try await UserIdentifierManager.shared.deleteCurrentAccount()
                await MainActor.run {
                    isDeletingAccount = false
                    dismiss()
                }
            } catch {
                await ErrorHandler.shared.handle(error)
                await MainActor.run {
                    isDeletingAccount = false
                }
            }
        }
    }
}

#Preview {
    HomeSettingView()
}
