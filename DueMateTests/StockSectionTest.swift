//
//  StockSectionTest.swift
//  DueMateTests
//
//  Created by Kacey Kim on 7/23/26.
//

import Foundation
import Testing
@testable import DueMate

struct StockSectionTest {
    @Test
    func section_forRemainingDays() {
        #expect(StockSection.section(for:7) == .inOneWeek)
        #expect(StockSection.section(for:14) == .inTwoWeeks)
        #expect(StockSection.section(for:15) == .later)
    }
}
