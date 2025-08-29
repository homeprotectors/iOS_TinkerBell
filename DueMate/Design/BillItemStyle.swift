//
//  BillItemStyle.swift
//  DueMate
//
//  Created by Kacey Kim on 8/14/25.
//

import Foundation
import SwiftUI

enum BillStatus {
    case overdue
    case paid
    case normal
    
}
struct BillItemStyle{
    let background: LinearGradient
    let textColor: Color
    let titleFont: Font
    let subtitleFont: Font
    
    static func style(for status: BillStatus) -> BillItemStyle {
        switch status {
        case .overdue:
            return BillItemStyle(
                background: ListStatus.overdue.gradient,
                textColor: ListColor.overdueText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10))
        case .paid:
            return BillItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.normalText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10))
        case .normal:
            return BillItemStyle(
                background: ListStatus.normal.gradient,
                textColor: ListColor.normalText,
                titleFont: .system(size: 22, weight: .bold),
                subtitleFont: .system(size:10))
            
        }
    }
}
