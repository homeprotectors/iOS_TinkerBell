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
        VStack(spacing: 0){
            headerView
            
            Picker("", selection: $quantity) {
                ForEach(0...300, id:\.self) { num in
                    Text("\(num) 개")
                        .tag(num)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 200, height: 200)
            .onChange(of: quantity) {
                calculateExpectedDays()
            }
            Group {
                Text("현재 약 \(expectedDaysLeft)일치가 남았어요!\n일주일치 이하로 떨어지면 자동으로 장보기 리스트에 나타납니다.")
                    .font(.listText)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryText)
                
            }
            .padding(.vertical, 10)
            
            Spacer()
        }
        .onAppear {
            calculateExpectedDays()
        }
        
        
    }
    
    private var headerView: some View {
        HStack{
            Spacer()
            Text("현재 \(item.name) 갯수")
                .font(.sheetTitle)
            Spacer()
        }
        .overlay(
            SaveButton(isEnabled: true, action:{
                onSave(quantity)
                dismiss()
            }, isEditMode: true)
            .frame(maxWidth: .infinity, alignment: .trailing)
        )
        .padding(.top, 30)
        .padding(.bottom,10)
    }
    private func calculateExpectedDays() {
        guard item.unitQuantity > 0 else {
            expectedDaysLeft = 0
            return
        }
        expectedDaysLeft = (quantity * item.unitDays) / item.unitQuantity
    }
}

#Preview {
    StockQuantityPickerView(quantity: .constant(3), item: StockItem(id: 1, name: "휴지", unitDays: 3, unitQuantity: 1, currentQuantity: 5, remainingDays: 10), onSave: {_ in })
}
