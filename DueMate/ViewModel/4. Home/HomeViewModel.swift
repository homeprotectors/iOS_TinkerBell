//
//  HomeViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 9/19/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class HomeViewModel: ObservableObject, ErrorReporting {
    @Published var homeList: [HomeSection] = []
    @Published var selectedItem: HomeItem? = nil
    @Published var selectedItemFrame: CGRect = .zero
    @Published var dragOffset: CGSize = .zero
    
    private let network = DefaultNetworkService.shared
    
    func fetchHome() async {
        await refreshHome()
    }

    func selectItem(_ item: HomeItem, frame: CGRect) {
        //진동
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        selectedItemFrame = frame
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedItem = item
        }
    }
    
    func dragEnded(_ translation: CGSize) {
        if translation.height < -150 || translation.height > 150 {
            if let selectedItem {
                completeHomeItem(selectedItem)
            }
            clearSelectedItem()
            
        } else {
            resetDragOffset()
        }
        
        
    }
    
    func clearSelectedItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)){
            selectedItem = nil
            dragOffset = .zero
        }
    }
    
    private func resetDragOffset() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            dragOffset = .zero
        }
    }
    
    private func completeHomeItem(_ item: HomeItem) {
        guard !item.shoppingContainer else { return }
        
        Task {
            do {
                let body = CompleteChoreRequest(
                    choreId: item.id,
                    doneDate: DateFormatter.yyyyMMdd.string(from: Date())
                )
                try await network.requestWithoutResponse(ChoreRouter.complete(body: body))
                await refreshHome()
            } catch {
                await reportError(error)
            }
        }
    }
    
    private func refreshHome() async {
        do {
            let response: HomeSectionsData = try await network.request(ChoreRouter.getHome)
            let rawSections = [
                HomeSection(title: "이번주 할 일", list: response.sections.thisWeek.items),
                HomeSection(title: "다음주 할 일", list: response.sections.nextWeek.items),
                HomeSection(title: "이번달 할 일", list: response.sections.thisMonth.items),
                HomeSection(title: "다음달 할 일", list: response.sections.nextMonth.items)
            ]
            homeList = rawSections.filter { !$0.list.isEmpty }
        } catch {
            await reportError(error)
        }
    }
    
}
