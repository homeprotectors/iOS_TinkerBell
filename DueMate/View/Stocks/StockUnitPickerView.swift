//
//  StockUnitPickerView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/26/25.
//

import SwiftUI

struct StockUnitPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var amount: Int
    @Binding var unit: String
    
    
    let unitOptions = ["개", "롤", "팩", "병", "장", "캔", "ml", "L", "g", "kg" ]
    
    var body: some View {
        VStack(spacing: 24) {
            HStack{
                Spacer()
                Button(action:{
                    self.dismiss()
                }){
                    Image(systemName: "xmark")
                        .font(.system(size: 20,weight: .bold))
                        .foregroundColor(.black)
                }
            }

            HStack {
                // consumption amount
                TextField("수량", value: $amount, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                // consumption unit
                Picker("단위 선택", selection: $unit) {
                    ForEach(unitOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(30)
        .background(.ultraThickMaterial)
        .presentationDetents([.height(300)])
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    StockUnitPickerView(amount: .constant(3), unit: .constant("개"))
}
