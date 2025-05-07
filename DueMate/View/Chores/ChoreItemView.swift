//
//  ChoreItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct ChoreItemView: View {
    
    let item: ChoreListItem
    let color: Color
    let onCheckToggled: () -> Void
   

    var body: some View {
        HStack{
            VStack(alignment:.leading){
                HStack{
                    Text(item.title)
                        .font(.system(size: 25, weight: .bold))
                    if item.reminderEnabled{
                        Image(systemName: "bell.fill")
                    }
                    
                }
                
                Text("\(item.cycleDays)일에 한 번")
            }
            Spacer()
            Text("D-")
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
    ChoreItemView(item: ChoreListItem(
        id: 1,
        title: "Take out trash",
        cycleDays: 3,
        nextDue: "2025-05-03",
        reminderEnabled: true
    ), color: ListColor.normal, onCheckToggled: {})
}
