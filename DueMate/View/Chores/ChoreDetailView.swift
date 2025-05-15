//
//  ChoreDetailView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/12/25.
//

import SwiftUI

struct ChoreDetailView: View {
    let item: ChoreListItem
    var body: some View {
        Text("item: \(item.title)")
    }
}

#Preview {
    ChoreDetailView(item: ChoreListItem(id: 1, title: "빨래하기", cycleDays: 3, nextDue: "2025-05-13", reminderEnabled: true))
}
