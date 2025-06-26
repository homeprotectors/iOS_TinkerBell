//
//  ChoreItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct ChoreItemView: View {
    
    let item: ChoreItem
    let color: LinearGradient
    let onCheckToggled: () -> Void
    var daysRemaining: Int {
        guard let remaining = item.nextDue.daysFromToday() else {
            return 0
        }
        return remaining
    }
    var status: ListStatus {
        switch daysRemaining {
        case ...0:
            return ListStatus.overdue
        case 1...3:
            return ListStatus.warning
        default:
            return ListStatus.normal
        }
    }
    var style: ItemStyle {
        ItemStyle.style(for: status)
    }
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment:.leading){
                    HStack{
                        Text(item.title)
                            .font(style.titleFont)
                            
                        if item.reminderDays != nil {
                            Image(systemName: "bell.fill")
                        }
                        
                    }
                    
                    Text("\(item.cycleDays)일에 한 번")
                }
                Spacer()
                
                if daysRemaining == 0 {
                    Text("D-Day")
                } else if daysRemaining < 0 {
                    Text("D+\(-daysRemaining)")
                } else {
                    Text("D-\(daysRemaining)")
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
    ChoreItemView(item: ChoreItem(
        id: 1,
        title: "Take out trash",
        cycleDays: 3,
        nextDue: "2025-05-03",
        reminderDays: 1
    ), color: ListStatus.normal.gradient, onCheckToggled: {})
}
