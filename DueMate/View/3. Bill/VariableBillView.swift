//
//  VariableBillView.swift
//  DueMate
//
//  Created by Kacey Kim on 11/14/25.
//

import SwiftUI

struct VariableBillView: View {
    var item: BillItem
    var month: Int
    var onSave: (Double) -> Void
    @State private var amountText: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            
            
            HStack {
                Spacer()
                Text("\(month)월 \(item.name)")
                    .font(.headline)
                Spacer()
            }
            .overlay(
                SaveButton(
                    isEnabled: Double(amountText) != nil,
                    action: {
                        if let value = Double(amountText) {
                            onSave(value)
                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            )
            
            
            HStack {
                Image("ic_krw")
                TextField("납부액", text: $amountText)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 8)
                    .background(Color.clear)
                
                Text("원")
            }
            .font(.body)
            .padding(.horizontal, 16)
            
            Spacer()
            
            
        }
        .padding(.top, 20)
    }
}

#Preview {
    VariableBillView(item: BillItem(id: 1, name: "수도세", isVariable: true, isPaid: false, amount: 0, dueDate: 1), month: 11, onSave: { _ in  })
}
