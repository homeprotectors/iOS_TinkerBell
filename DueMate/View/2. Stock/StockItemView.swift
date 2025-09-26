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
        switch item.currentQuantity {
        case ...2:
            return "stock_lowest"
        case ...4:
            return "stock_low"
        case ...5:
            return "stock_mid"
        case ...10:
            return "stock_high"
        default:
            return "stock_full"
        }
    }
    
    
    var body: some View {
        VStack{
            HStack(spacing: 16){
                Text(item.name)
                    .font(.listTitle)
                Spacer()
                HStack {
                    Text("\(item.currentQuantity)")
                        .font(.system(size: 20, weight: .bold))
                    Image(QuantityLevel)
                }
                .onTapGesture {
                    onTapGesture(item)
                }
                
            }
            .padding(22)
            Divider()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StockItemView(item: StockItem(id: 1, name: "휴지",  unitDays: 3, unitQuantity: 1, currentQuantity: 5, remainingDays: 1), onTapGesture: {_ in print("눌림")})
}
