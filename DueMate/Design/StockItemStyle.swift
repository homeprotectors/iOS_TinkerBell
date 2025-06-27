//
//  StockItemStyle.swift
//  DueMate
//
//  Created by Kacey Kim on 6/26/25.
//

import Foundation
import SwiftUI

struct StockItemStyle {
    let background: LinearGradient
    let textColor: Color
    let titleFont: Font
    let subtitleFont: Font
    let numberFont: Font
    
    static func style(for status: ListStatus) -> StockItemStyle {
        switch status {
        case .overdue:
            return StockItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.overdueText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10),
                numberFont: .system(size:45))
        case .warning:
            return StockItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.warningText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10),
                numberFont: .system(size:45))
        case .normal:
            return StockItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.normalText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10),
                numberFont: .system(size:45))
            
        }
    }
}
