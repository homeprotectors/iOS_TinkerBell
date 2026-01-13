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
    let item: StockItem
    let onSave: (Int) -> Void
    @State private var expectedDaysLeft: Int = 0
    
    
    var body: some View {
        VStack {
            Text("\(item.name) 몇 개가 남아 있나요?")
            Picker("", selection: $quantity) {
                ForEach(0...300, id:\.self) { num in
                    Text("\(num) 개")
                        .tag(num)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 200)
            .onChange(of: quantity) {
                calculateExpectedDays()
            }
            Group {
                Text("현재 약 \(expectedDaysLeft)일치가 남았어요!")
                    .font(.listText)
                    .foregroundColor(.secondary)
                
                
            }
            SaveButton(isEnabled: true) {
                onSave(quantity)
                dismiss()
            }
            
        }
        .padding(16)
        .onAppear {
            calculateExpectedDays()
        }
        
        
    }
    
    private func calculateExpectedDays() {
        expectedDaysLeft = (quantity * item.unitDays) / item.unitQuantity
    }
}

#Preview {
    StockQuantityPickerView(quantity: .constant(3), item: StockItem(id: 1, name: "휴지", unitDays: 3, unitQuantity: 1, currentQuantity: 5, remainingDays: 10), onSave: {_ in })
}
