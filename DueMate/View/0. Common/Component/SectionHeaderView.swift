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
        .padding(.horizontal, 18)
        .padding(.vertical, 5)
        .listRowInsets(EdgeInsets())
        .background(Color.white)
    }
}
#Preview {
    SectionHeaderView(title: "이번주")
}
