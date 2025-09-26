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
    
    var body: some View {
        VStack {
            Text("몇 개가 남아 있나요?")
            Picker("", selection: $quantity) {
                ForEach(1...300, id:\.self) { num in
                    Text("\(num)")
                        .tag(num)
                }
            }.pickerStyle(.wheel)
            SaveButton(isEnabled: true) {
                print("저장")
            }
            
        }
        .padding(16)
        
    }
}

#Preview {
    StockQuantityPickerView(quantity: .constant(3))
}
