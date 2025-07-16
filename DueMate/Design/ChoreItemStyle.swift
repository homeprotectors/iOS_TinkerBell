//
//  ItemStyle.swift
//  DueMate
//
//  Created by Kacey Kim on 6/23/25.
//

import Foundation
import SwiftUI

struct ChoreItemStyle {
    let background: LinearGradient
    let textColor: Color
    let titleFont: Font
    let subtitleFont: Font
    
    static func style(for status: ListStatus) -> ChoreItemStyle {
        switch status {
        case .overdue:
            return ChoreItemStyle(
                background: ListStatus.overdue.gradient,
                textColor: ListColor.overdueText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10))
        case .warning:
            return ChoreItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.normalText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10))
        case .normal:
            return ChoreItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.normalText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10))
            
        }
    }
}
