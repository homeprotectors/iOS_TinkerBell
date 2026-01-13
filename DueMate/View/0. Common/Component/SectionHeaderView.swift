//
//  SectionHeaderView.swift
//  DueMate
//
//  Created by Kacey Kim on 10/10/25.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.listText)
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 0)
        .listRowInsets(EdgeInsets())
        .background(Color.white)
    }
}
#Preview {
    SectionHeaderView(title: "이번주")
}
