//
//  BillItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 8/9/25.
//

import SwiftUI

struct BillItemView: View {
    let item: BillItem
    let onCheckToggled: () -> Void
    var daysRemaining: Int {
        let date = Calendar.current.component(.day, from: Date())
        return item.dueDate - date
    }
    var status: BillStatus {
        if item.isPaid { return BillStatus.paid}
        else if daysRemaining <= 0 { return BillStatus.overdue}
        else { return BillStatus.normal }
    }
    
    var style: BillItemStyle {
        BillItemStyle.style(for: status)
    }
    
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment:.leading){
                    HStack{
                        Text(item.title)
                    }
                    
                }
                Spacer()
                
            }
            .padding()
            
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .cornerRadius(35)
        
    }
}

#Preview {
    BillItemView(item: BillItem(id: 1, title: "넷플릭스", isFixed: true, isPaid: false, amount: 24000, dueDate: 25, reminderDays: nil), onCheckToggled: {})
}
