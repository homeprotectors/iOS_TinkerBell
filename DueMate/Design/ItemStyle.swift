//
//  ItemStyle.swift
//  DueMate
//
//  Created by Kacey Kim on 6/23/25.
//

import Foundation
import SwiftUI

struct ItemStyle {
    let background: LinearGradient
    let textColor: Color
    let titleFont: Font
    let subtitleFont: Font
    
    static func style(for status: ListStatus) -> ItemStyle {
        switch status {
        case .overdue:
            return ItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.overdueText,
                titleFont: .system(size: 20, weight: .bold),
                subtitleFont: .system(size:14))
        case .warning:
            return ItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.warningText,
                titleFont: .system(size: 20, weight: .bold),
                subtitleFont: .system(size:14))
        case .normal:
            return ItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.normalText,
                titleFont: .system(size: 20, weight: .bold),
                subtitleFont: .system(size:14))
            
        }
    }
}
