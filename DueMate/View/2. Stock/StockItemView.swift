//
//  StockItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockItemView: View {
    let item: StockItem
    let onTapGesture: (StockItem) -> Void
    var QuantityLevel: String {
        switch item.remainingDays {
        case ...3:
            return "stock_lowest"
        case 4...7:
            return "stock_low"
        case 8...14:
            return "stock_med"
        case 15...21:
            return "stock_high"
        default:
            return "stock_full"
        }
    }
    
    
    var body: some View {
        VStack(spacing:0){
            HStack(spacing: 20){
                Text(item.name)
                    .font(.listTitle)
                    .foregroundColor(Color.primaryText)
                Spacer()
                HStack {
                    Text("\(item.currentQuantity) 개")
                        .font(.listSubitem)
                        .foregroundColor(Color.primaryText)
                    Image("arrow_double")
                        .padding(.trailing,10)
                    Image(QuantityLevel)
                }
                .onTapGesture {
                    onTapGesture(item)
                }
                
            }
            .padding(.horizontal,22)
            .padding(.vertical,18)
            
            Rectangle()
                .frame(height: 1)        
                .foregroundColor(.lightGray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 68)
        
        
    }
}

#Preview {
    StockItemView(item: StockItem(id: 1, name: "휴지",  unitDays: 3, unitQuantity: 1, currentQuantity: 5, remainingDays: 1), onTapGesture: {_ in print("눌림")})
}
