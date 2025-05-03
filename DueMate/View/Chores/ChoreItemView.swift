//
//  ChoreItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct ChoreItemView: View {
    var item: ChoreListItem
    var body: some View {
        HStack{
            VStack(alignment:.leading){
                HStack{
                    Text(item.title)
                        .font(.system(size: 25, weight: .bold))
                    Image(systemName: "bell.fill")
                }
                
                Text("\(item.cycleDays)일에 한 번")
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.yellow)
        .cornerRadius(20)
        
    }
}

#Preview {
    ChoreItemView(item: ChoreListItem(
        id: 1,
        title: "Take out trash",
        cycleDays: 3,
        nextDueDate: "2025-05-03",
        reminderEnabled: true
    ))
}
