//
//  StockItemView.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import SwiftUI

struct StockItemView: View {
    let item: StockItem
    let percentage: Int
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    StockItemView(item: StockItem(id: 1, title: "휴지", unitDays: 3, unitAmount: 1, unit: "롤", nextDue: "2025-06-29"), percentage: 70)
}
