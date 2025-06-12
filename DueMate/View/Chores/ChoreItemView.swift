//
//  ChoreItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct ChoreItemView: View {
    
    let item: ChoreItem
    let color: Color
    let onCheckToggled: () -> Void
    var daysRemaining: Int? {
        item.nextDue.daysFromToday()
    }

    var body: some View {
        HStack{
            VStack(alignment:.leading){
                HStack{
                    Text(item.title)
                        .font(.system(size: 25, weight: .bold))
                    if item.reminderDays != nil {
                        Image(systemName: "bell.fill")
                    }
                    
                }
                
                Text("\(item.cycleDays)일에 한 번")
            }
            Spacer()
            if let daysRemaining = daysRemaining {
                if daysRemaining == 0 {
                    Text("D-Day")
                } else if daysRemaining < 0 {
                    Text("D+\(-daysRemaining)")
                } else {
                    Text("D-\(daysRemaining)")
                }
            } else {
                Text("D-?")
            }
            
            Button(action:onCheckToggled){
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(20)
        
    }
}

#Preview {
    ChoreItemView(item: ChoreItem(
        id: 1,
        title: "Take out trash",
        cycleDays: 3,
        nextDue: "2025-05-03",
        reminderDays: 1
    ), color: ListColor.normal, onCheckToggled: {})
}
