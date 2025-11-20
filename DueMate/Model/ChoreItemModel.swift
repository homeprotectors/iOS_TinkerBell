//
//  ChoreModel.swift
//  DueMate
//
//  Created by Kacey Kim on 10/18/25.
//

import Foundation

struct ChoreItem: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let recurrenceType: String
    let selectedCycle: [String]?
    let roomCategory: String
    let nextDue: String

    
    var recurrenceDescription: String {
        switch recurrenceType {
        case "PER_WEEK":
            return "일주일에 1번"
        case "PER_2WEEKS":
            return "2주일에 1번"
        case "PER_MONTH":
            return "한 달에 1번"
        case "FIXED_DAY":
            guard let days = selectedCycle else { return "고정 요일 없음" }
            let sortedEnum = days.compactMap{ DayOptions(rawValue: $0)}.sorted{ $0.order < $1.order }
            let koreanDays = sortedEnum.compactMap { $0.display }.joined(separator: ", ")
            return "매주 \(koreanDays)"
        case "FIXED_DATE":
            guard let dates = selectedCycle else { return "고정 일자 없음" }
            let sorted = dates.sorted {
                if $0 == "END" { return false }
                if $1 == "END" { return true }
                return (Int($0) ?? 0) < (Int($1) ?? 0) }
            let formatted = sorted.compactMap { $0 == "END" ? "말일" : "\($0)일" }.joined(separator: ", ")
            return "매월 \(formatted)"
        case "FIXED_MONTH":
            guard let months = selectedCycle else { return "고정 월 없음" }
            let sorted = months.sorted{ (Int($0) ?? 0) < (Int($1) ?? 0) }
            let formatted = sorted.map { "\($0)월" }.joined(separator: ", ")
            return "매년 \(formatted)"
        default:
            return ""
        }
    }
    
    var recurrenceTypeEnum: CycleOption {
        switch recurrenceType {
        case "PER_WEEK":
            return .simple(.weekly)
        case "PER_2WEEKS":
            return .simple(.biweekly)
        case "PER_MONTH":
            return .simple(.monthly)
        case "FIXED_DAY":
            return .fixed(.day)
        case "FIXED_DATE":
            return .fixed(.date)
        case "FIXED_MONTH":
            return .fixed(.month)
        default:
            return .simple(.weekly)
        }
    }
}

extension ChoreItem {
    init(from item: ChoreItemResponse) {
        self.id = item.id
        self.title = item.title
        self.recurrenceType = item.recurrenceType
        self.selectedCycle = item.selectedCycle
        self.roomCategory = item.roomCategory.lowercased()
        self.nextDue = item.nextDue
    }
}
