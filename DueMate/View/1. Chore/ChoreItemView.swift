//
//  ChoreItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct ChoreItemCard: View {
    let item: ChoreItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image("ic_\(item.roomCategory)")
                .padding(11)
                .background(Color.backgroundBlue)
                .cornerRadius(4)
            
            Text(item.title)
                .font(.listTitle)
            
            Spacer()
            
            
            Text(item.recurrenceDescription)
                .font(.listText)
                .frame(maxWidth: 150, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .allowsTightening(false)
                
            
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    ChoreItemCard(item: ChoreItem(
        id: 1,
        title: "쓰레기 버리기",
        recurrenceType: "FIXED_DATE",
        selectedCycle: ["1", "2", " 5", "22", "12","27","30"],
        roomCategory: "living",
        nextDue: "2025-05-03"
    ))
}
