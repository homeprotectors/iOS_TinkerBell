//
//  CycleOption.swift
//  DueMate
//
//  Created by Kacey Kim on 10/1/25.
//

import Foundation

enum CycleOption: Equatable {
    case simple(SimpleCycleOption)
    case fixed(FixedCycleOption)
    
    var display: String {
        switch self {
        case .simple(let option): return option.display
        case .fixed(let option) : return option.display
        }
    }
    
    init(rule: RecurrenceRule) {
        switch rule {
        case .perWeek:
            self = .simple(.weekly)
        case .per2Weeks:
            self = .simple(.biweekly)
        case .perMonth:
            self = .simple(.monthly)
        case .fixedDay:
            self = .fixed(.day)
        case .fixedDate:
            self = .fixed(.date)
        case .fixedMonth:
            self = .fixed(.month)
        }
    }
    
}


enum SimpleCycleOption: String, CaseIterable {
    case weekly, biweekly, monthly
    
    var display: String {
        switch self {
        case .weekly: return "1주에 1번"
        case .biweekly: return "2주에 1번"
        case .monthly: return "한달에 1번"
        }
    }
}

enum FixedCycleOption: String, CaseIterable {
    case day, date, month
    
    var display: String {
        switch self {
        case .day: return "요일"
        case .date: return "날짜"
        case .month: return "달"
        }
    }
}

protocol DetailCycleOption: CaseIterable, Hashable {
    var serverData: String { get }
    var display: String { get }
}

enum DayOptions: String, DetailCycleOption {
    case MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
    
    var serverData: String { rawValue }
    var display: String {
        switch self {
        case .MONDAY: return "월"
        case .TUESDAY: return "화"
        case .WEDNESDAY: return "수"
        case .THURSDAY: return "목"
        case .FRIDAY: return "금"
        case .SATURDAY: return "토"
        case .SUNDAY: return "일"
        }
    }
    
    var order: Int {
        switch self {
        case .MONDAY: return 1
        case .TUESDAY: return 2
        case .WEDNESDAY: return 3
        case .THURSDAY: return 4
        case .FRIDAY: return 5
        case .SATURDAY: return 6
        case .SUNDAY: return 7
        }
    }
    
}

enum DateOptions: DetailCycleOption {
    case day(Int)
    case endOfMonth
    
    static var allCases: [DateOptions] {
        var cases: [DateOptions] = []
        for i in 1...30 {
            cases.append(.day(i))
        }
        cases.append(.endOfMonth)
        return cases
    }
    
    var display: String {
        switch self {
        case .day(let day):
            return "\(day)"
        case .endOfMonth:
            return "마지막일"
        }
    }
    
    var serverData: String {
        switch self {
        case .day(let day):
            return "\(day)"
        case .endOfMonth:
            return "END"
        }
    }
    
}

enum MonthOptions: String, DetailCycleOption {
    case jan = "1"
    case feb = "2"
    case mar = "3"
    case apr = "4"
    case may = "5"
    case jun = "6"
    case jul = "7"
    case aug = "8"
    case sep = "9"
    case oct = "10"
    case nov = "11"
    case dec = "12"
    
    var serverData: String { rawValue }
    var display: String {
        return "\(rawValue)월"
    }
    
}
