//
//  TutorialManager.swift
//  DueMate
//
//  Created by Kacey Kim on 11/21/25.
//

import Foundation

/// 튜토리얼 완료 여부를 관리하는 매니저
final class TutorialManager {
    static let tutorialCompletedKey = "tutorialCompleted"
    static let ChoreTutorialCompletedKey = "ChoreTutorialCompleted"
    static let StockTutorialCompletedKey = "StockTutorialCompleted"
    static let BillTutorialCompletedKey = "BillTutorialCompleted"
    
    /// 튜토리얼 완료 여부를 확인합니다.
    static var isTutorialCompleted: Bool {
        //UserDefaults.standard.bool(forKey: tutorialCompletedKey)
        false
    }
    
    /// 튜토리얼을 완료 처리합니다.
    static func completeTutorial() {
        UserDefaults.standard.set(true, forKey: tutorialCompletedKey)
    }
    
    /// 튜토리얼 완료 상태를 리셋합니다. (디버깅용)
    static func resetTutorial() {
        UserDefaults.standard.removeObject(forKey: tutorialCompletedKey)
        UserDefaults.standard.removeObject(forKey: ChoreTutorialCompletedKey)
        UserDefaults.standard.removeObject(forKey: StockTutorialCompletedKey)
        UserDefaults.standard.removeObject(forKey: BillTutorialCompletedKey)
    }
    
    // MARK: - Tab Tutorials
    
    /// Chore 탭 튜토리얼 완료 여부를 확인합니다.
    static var isChoreTutorialCompleted: Bool {
        UserDefaults.standard.bool(forKey: ChoreTutorialCompletedKey)
    }
    
    /// Chore 탭 튜토리얼을 완료 처리합니다.
    static func completeChoreTutorial() {
        UserDefaults.standard.set(true, forKey: ChoreTutorialCompletedKey)
    }
    
    /// Stock 탭 튜토리얼 완료 여부를 확인합니다.
    static var isStockTutorialCompleted: Bool {
        UserDefaults.standard.bool(forKey: StockTutorialCompletedKey)
    }
    
    /// Stock 탭 튜토리얼을 완료 처리합니다.
    static func completeStockTutorial() {
        UserDefaults.standard.set(true, forKey: StockTutorialCompletedKey)
    }
    
    /// Bill 탭 튜토리얼 완료 여부를 확인합니다.
    static var isBillTutorialCompleted: Bool {
        UserDefaults.standard.bool(forKey: BillTutorialCompletedKey)
    }
    
    /// Bill 탭 튜토리얼을 완료 처리합니다.
    static func completeBillTutorial() {
        UserDefaults.standard.set(true, forKey: BillTutorialCompletedKey)
    }
}

