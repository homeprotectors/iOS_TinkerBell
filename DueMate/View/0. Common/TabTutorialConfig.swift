//
//  TabTutorialConfig.swift
//  DueMate
//
//  Created by Kacey Kim on 12/XX/25.
//

import Foundation

/// 탭별 튜토리얼 설정을 담는 구조체
struct TabTutorialConfig {
    let message: String
    let isCompleted: () -> Bool
    let completeTutorial: () -> Void
}
