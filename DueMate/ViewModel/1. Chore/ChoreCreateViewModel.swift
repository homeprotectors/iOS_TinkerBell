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
    
    @Published var selectedDays: Set<DayOptions> = []
    @Published var selectedDates: Set<DateOptions> = []
    @Published var selectedMonths: Set<MonthOptions> = []
    
    
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
    
    // - Network
    func createChore() {
        print("==> Creating Chore")
        
        
        let body = CreateChoreRequest(
            title: title
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
                if let nwError = error as? NetworkError {
                    await ErrorHandler.shared.handle(nwError)
                } else {
                    print("💥 ErrorHandling Failed:  \(error.localizedDescription)")
                }
            }
            
        }
    }
    
}


