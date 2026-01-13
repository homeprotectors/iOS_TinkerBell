//
//  HomeViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 9/19/25.
//

import Foundation
import SwiftUI
import UIKit

class HomeViewModel: ObservableObject {
    @Published var homeList: [HomeSection] = []
    @Published var selectedItem: HomeItem? = nil
    @Published var selectedItemFrame: CGRect = .zero
    @Published var dragOffset: CGSize = .zero
    
    private let network = DefaultNetworkService.shared
    
    func fetchHome() {
        Task {
            do {
                let response: HomeSectionsData = try await network.request(ChoreRouter.getHome)
            
                await MainActor.run {
                    let rawSections = [
                        HomeSection(title: "이번주 할 일", list: response.sections.thisWeek.items),
                        HomeSection(title: "다음주 할 일", list: response.sections.nextWeek.items),
                        HomeSection(title: "이번달 할 일", list: response.sections.thisMonth.items),
                        HomeSection(title: "다음달 할 일", list: response.sections.nextMonth.items)
                    ]
                    self.homeList = rawSections.filter { !$0.list.isEmpty }
                }
                print("🎉 Home fetch 성공!")
            } catch {
                await MainActor.run {
                    ErrorHandler.shared.handle(error)
                }
            }
        }
    }
    
    
    
    
    private func generateCycleString(recurrenceType: String?, selectedCycle: [String]?) -> String {
        guard let recurrenceType = recurrenceType else {
            return ""
        }
        
        switch recurrenceType {
        case "PER_WEEK":
            return "일주일에 1번"
        case "PER_2WEEKS":
            return "2주일에 1번"
        case "PER_MONTH":
            return "한 달에 1번"
        case "FIXED_DAY":
            guard let days = selectedCycle, !days.isEmpty else { return "고정 요일 없음" }
            let sortedEnum = days.compactMap { DayOptions(rawValue: $0) }.sorted { $0.order < $1.order }
            let koreanDays = sortedEnum.map { $0.display }.joined(separator: ", ")
            return "매주 \(koreanDays)"
        case "FIXED_DATE":
            guard let dates = selectedCycle, !dates.isEmpty else { return "고정 일자 없음" }
            let sorted = dates.sorted {
                if $0 == "END" { return false }
                if $1 == "END" { return true }
                return (Int($0) ?? 0) < (Int($1) ?? 0)
            }
            let formatted = sorted.compactMap { $0 == "END" ? "말일" : "\($0)일" }.joined(separator: ", ")
            return "매월 \(formatted)"
        case "FIXED_MONTH":
            guard let months = selectedCycle, !months.isEmpty else { return "고정 월 없음" }
            let sorted = months.sorted { (Int($0) ?? 0) < (Int($1) ?? 0) }
            let formatted = sorted.map { "\($0)월" }.joined(separator: ", ")
            return "매년 \(formatted)"
        default:
            return ""
        }
    }
    
    func selectItem(_ item: HomeItem, frame: CGRect) {
        //진동
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        selectedItemFrame = frame
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedItem = item
        }
        print("\(item.title) 누름, \(frame)")
        
    }
    
    func dragEnded(_ translation: CGSize) {
        if translation.height < -50 {
            print("complete")
        }else if translation.height > 50 {
            print("cancel")
            
        }
        clearSelectedItem()
    }
    
    func clearSelectedItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)){
            selectedItem = nil
            dragOffset = .zero
        }
    }
    
}
