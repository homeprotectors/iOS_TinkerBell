//
//  StockQuantityPickerView.swift
//  DueMate
//
//  Created by Kacey Kim on 9/26/25.
//

import SwiftUI

struct StockQuantityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var quantity: Int
    let name: String
    let onSave: (Int) -> Void
    
    var body: some View {
        VStack {
            Text("\(name) 몇 개가 남아 있나요?")
            Picker("", selection: $quantity) {
                ForEach(0...300, id:\.self) { num in
                    Text("\(num)")
                        .tag(num)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 200)
            SaveButton(isEnabled: true) {
                onSave(quantity)
            }
            
        }
        .padding(16)
        
    }
}

#Preview {
    StockQuantityPickerView(quantity: .constant(3), name: "휴지", onSave: {_ in })
}
