//
//  StockItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockItemView: View {
    let item: StockItem
    let onCheckToggled: () -> Void
    var daysRemaining: Int {
        guard let remaining = item.nextDue.daysFromToday() else {
            return 0
        }
        return remaining
    }
    var status: ListStatus {
        if daysRemaining < 0 { return .overdue }
        else if daysRemaining <= 3 { return .warning}
        else { return .normal }
    }
    var style: StockItemStyle {
        StockItemStyle.style(for: status)
    }
    
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment:.leading){
                    HStack{
                        Text(item.title)
                            .font(style.titleFont)
                        
                        
                    }
                    Text("\(item.unitDays)일에 \(item.unitAmount)\(item.unit)")
                }
                Spacer()
                
                HStack{
                    Text("약 \(daysRemaining)일치")
                }
                
                Button(action:onCheckToggled){
                    Image(systemName: "staroflife.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(style.textColor)
                    
                }
                .padding(5)
                
            }
            .padding()
            .overlay(
                Rectangle()
                    .stroke(style: StrokeStyle(dash:[4]))
            )
            
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(style.background)
        .foregroundColor(style.textColor)
    }
}

#Preview {
    StockItemView(item: StockItem(id: 1, title: "휴지", unitDays: 3, unitAmount: 1, unit: "롤", nextDue: "2025-06-29"), onCheckToggled: {})
}
