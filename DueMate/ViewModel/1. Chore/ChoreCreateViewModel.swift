//
//  ChoreCreateViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 4/30/25.
//

import Foundation
import SwiftUI
import Alamofire



class ChoreCreateViewModel: ObservableObject {
    @Published var isChoreCreated = false
    @Published var title: String = ""
    @Published var category: String = "living"
    @Published var isFixedCycle: Bool = false
    @Published var cycleOption: CycleOption = .simple(.weekly)
    
    
    @Published var selectedDays: Set<String> = []
    @Published var selectedDates: Set<String> = []
    @Published var selectedMonths: Set<String> = []
    
    @Published var isUpdatingMode: Bool = false
    
    private var originalItem: ChoreItem?
    
    // Form Validation
    var isFormValid: Bool {
        let isTitleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        guard isTitleValid else { return false }
        
        if !isFixedCycle {
            return true
        }
        
        return !selectedDays.isEmpty || !selectedDates.isEmpty || !selectedMonths.isEmpty
        
    }
    
    func clearSelectedOptions() {
        selectedDays = []
        selectedDates = []
        selectedMonths = []
    }
    
    func setupForUpdate(_ item: ChoreItem){
        isUpdatingMode = true
        defer {
            DispatchQueue.main.async {
                self.isUpdatingMode = false
            }
        }
        
        originalItem = item
        title = item.title
        category = item.roomCategory
        
        // isFixedCycle을 먼저 설정
        switch item.recurrenceTypeEnum {
        case .simple(_):
            isFixedCycle = false
        case .fixed(_):
            isFixedCycle = true
        }
        
        // 그 다음 cycleOption 설정
        cycleOption = item.recurrenceTypeEnum
        
        // 마지막으로 선택된 값들 설정
        switch cycleOption {
        case .simple(_):
            break
        case .fixed(let option):
            switch option {
            case .date:
                selectedDates = Set(item.selectedCycle ?? [])
            case .day:
                selectedDays = Set(item.selectedCycle ?? [])
            case .month:
                selectedMonths = Set(item.selectedCycle ?? [])
            }
        }
    }
    
    // - Network
    func createChore() {
        print("==> Creating Chore")
        print("cycleOption: \(cycleOption)")
        var selectedCycle: Set<String>? = nil
        if cycleOption == .fixed(.date) {
            selectedCycle = selectedDates
        }else if cycleOption == .fixed(.day) {
            selectedCycle = selectedDays
        }else if cycleOption == .fixed(.month) {
            selectedCycle = selectedMonths
        }
        let body = CreateChoreRequest(
            title: title,
            recurrenceType: cycleOption.serverData,
            selectedCycle: selectedCycle.map { Array($0) } ?? nil,
            roomCategory: category.uppercased()
        )
        
        print(body)
        Task {
            do {
                try await DefaultNetworkService.shared.requestWithoutResponse(ChoreRouter.create(body: body))
                await MainActor.run {
                    isChoreCreated = true
                    print("🎉 생성 완료! \(title)")
                }
            }
            catch {
                await MainActor.run {
                    ErrorHandler.shared.handle(error)
                }
            }
            
        }
    }
    
    func updateChore() {
        
    }
    
}


