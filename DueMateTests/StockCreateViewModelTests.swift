//
//  StockCreateViewModelTests.swift
//  DueMateTests
//
//  Created by Kacey Kim on 7/26/26.
//

import Testing
@testable import DueMate

@MainActor
struct StockCreateViewModelTests {
    @Test
    func formInvalid_whenTitleIsEmpty() {
        let vm = StockCreateViewModel()
        
        vm.title = ""
        vm.unitDays = 9
        vm.unitQuantity = 2
        
        #expect(vm.isFormValid == false)
    }
    
    @Test
    func formInvalid_whenUnitDaysIsZero() {
        let vm = StockCreateViewModel()
        
        vm.title = "Test"
        vm.unitDays = 0
        vm.unitQuantity = 2
        
        #expect(vm.isFormValid == false)
    }
}
