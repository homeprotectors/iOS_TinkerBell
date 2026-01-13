//
//  StockSection.swift
//  DueMate
//
//  Created by Kacey Kim on 9/26/25.
//

import Foundation

enum StockSection: CaseIterable, Hashable {
    case inOneWeek      // ≤ 7
    case inTwoWeeks      // 8...14
    case later         // > 14

    var title: String {
        switch self {
        case .inOneWeek: return "일주일 내로 사야 할 것"
        case .inTwoWeeks: return "2주 내로 사야 할 것"
        case .later:    return "그 이후 사야 할 것"
        }
    }

    static func section(for remainingDays: Int) -> StockSection {
        switch remainingDays {
        case ...7:      return .inOneWeek
        case 8...14:    return .inTwoWeeks
        default:        return .later
        }
    }
}
