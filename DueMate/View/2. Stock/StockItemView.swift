//
//  StockItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockItemView: View {
    let item: StockItem
    
    var daysRemaining: Int {
        guard let remaining = item.nextDue.daysFromToday() else {
            return 0
        }
        return remaining
    }
    
    var status: ListStatus {
        if daysRemaining <= 0 { return .overdue }
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
                    Text("\(item.unitDays)일에 \(item.unitQuantity)\(item.unit)")
                }
                Spacer()
                
                
                Text("\(item.currentQuantity)")
                    .font(.system(size: 40, weight: .bold))
                Text("\(item.unit)")
                    .font(.system(size: 25, weight: .medium))
                
            }
            .padding()
            
        }
        .padding(8)
        .background(style.background)
        .frame(maxWidth: .infinity)
        .cornerRadius(35)
        .foregroundColor(style.textColor)
    }
}

#Preview {
    StockItemView(item: StockItem(id: 1, title: "휴지", unitDays: 3, unitQuantity: 1, unit: "롤", currentQuantity: 10,nextDue: "2025-06-29", reminderDays: 1))
}
