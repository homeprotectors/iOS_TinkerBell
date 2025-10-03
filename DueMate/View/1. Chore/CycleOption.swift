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
    case mon, tue, wed, thu, fri, sat, sun
    
    var serverData: String { rawValue }
    var display: String {
        switch self {
        case .mon: return "월"
        case .tue: return "화"
        case .wed: return "수"
        case .thu: return "목"
        case .fri: return "금"
        case .sat: return "토"
        case .sun: return "일"
        }
    }
    
}

enum DateOptions: String, DetailCycleOption {
    case first, middle, last, custom
    
    var serverData: String {
        switch self {
        case .first: return "1"
        case .middle: return "15"
        case .last: return "last"
        case .custom: return "custom"
        }
    }
    
    var display: String {
        switch self {
        case .first: return "1일"
        case .middle: return "15일"
        case .last: return "마지막 일"
        case .custom: return "특정일"
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
