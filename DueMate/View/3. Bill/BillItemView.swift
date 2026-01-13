//
//  BillItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 8/9/25.
//

import SwiftUI

struct BillItemView: View {
    let item: BillItem
    let onTapped: () -> Void
    
    var body: some View {
        VStack(spacing:0) {
            HStack{
                HStack{
                    Text(item.name)
                        .font(.listTitle)
                }
                Spacer()
                if item.isVariable && !item.isPaid {
                    Button(action: {
                        onTapped()
                    }) {
                        Text("납부액 입력")
                            .font(.buttonText)
                            .foregroundColor(Color.accentColor)
                    }
                }
                else {
                    VStack(alignment:.trailing, spacing: 8){
                        Text("매월 \(item.dueDate)")
                        Text(item.amount, format: .currency(code: "KRW"))
                    }
                    .font(.listText)
                }
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lightGray)
        }
        .frame(height: 68)
        
    }
}

#Preview {
    BillItemView(item: BillItem(id: 1, name:"넷플릭스",  isVariable: false, isPaid: false, amount: 24000, dueDate: 15), onTapped: {})
}
