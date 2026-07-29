//
//  RecurrenceMapperTests.swift
//  DueMateTests
//
//  Created by Kacey Kim on 7/26/26.
//

import Testing
@testable import DueMate

struct RecurrenceMapperTests {
    // RecurrenceDTO -> RecurrenceRule
    @Test
    func fromDTO_mapsFixedDay() {
        let dto = RecurrenceDTO(recurrenceType: "FIXED_DAY", selectedCycle: ["TUESDAY","WEDNESDAY","MONDAY"])
        let result = RecurrenceMapper.fromDTO(dto)
        
        #expect(result == .fixedDay([.MONDAY,.TUESDAY,.WEDNESDAY]))
    }
    
    @Test
    func fromDTO_mapsFixedDate() {
        let dto = RecurrenceDTO(recurrenceType: "FIXED_DATE", selectedCycle: ["3","END","22"])
        let result = RecurrenceMapper.fromDTO(dto)
        
        #expect(result == .fixedDate([.day(3), .day(22), .endOfMonth]))
    }
    
    //RecurrenceRule -> RecurrenceDTO
    @Test
    func toDTO_sortsFixedDateCorrectly() {
        let result = RecurrenceMapper.toDTO(.fixedDate([.endOfMonth,.day(12), .day(3)]))
        
        #expect(result == RecurrenceDTO(recurrenceType: "FIXED_DATE", selectedCycle:["3","12","END"] ))
    }
    
    @Test
    func toDTO_sortsFixedDayCorrectly() {
        let result = RecurrenceMapper.toDTO(.fixedDay([.FRIDAY,.MONDAY]))
        
        #expect(result == RecurrenceDTO(recurrenceType: "FIXED_DAY", selectedCycle: ["MONDAY", "FRIDAY"]))
    }
    
    @Test
    func toDTO_sortsFixedMonthCorrectly() {
        let result = RecurrenceMapper.toDTO(.fixedMonth([.dec,.feb]))
        
        #expect(result == RecurrenceDTO(recurrenceType: "FIXED_MONTH", selectedCycle: ["2", "12"]))
    }
    
}
