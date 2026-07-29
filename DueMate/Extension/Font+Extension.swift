//
//  Font+Extension.swift
//  DueMate
//
//  Created by Kacey Kim on 9/17/25.
//

import Foundation
import SwiftUI

extension Font {
    private static func app(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        
        switch weight {
        case .light:
            fontName = "NanumSquareRoundOTFL"
        case .bold:
            fontName = "NanumSquareRoundOTFB"
        case .heavy:
            fontName = "NanumSquareRoundOTFEB"
        default:
            fontName = "NanumSquareRoundOTFR"
        }
        
        return .custom(fontName, size: size)
    }
    
    
    static var headerTitle: Font { app(size: 28, weight: .heavy) }
    static var sheetTitle: Font { app(size: 18, weight: .bold) }
    static var listTitle: Font { app(size: 16, weight: .bold) }
    static var listTitleMedium: Font { app(size: 16, weight: .medium) }
    static var listSubitem: Font { app(size: 14, weight: .bold) }
    static var buttonText: Font { app(size: 14, weight: .bold) }
    static var buttonLight: Font { app(size: 14, weight: .light) }
    static var listText: Font { app(size: 12, weight: .light) }
    static var formlabel: Font { app(size: 12, weight: .medium) }
    static var smallButtonText: Font { app(size: 12, weight: .bold) }
}
