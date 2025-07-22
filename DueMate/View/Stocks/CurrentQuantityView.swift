//
//  CurrentQuantityView.swift
//  DueMate
//
//  Created by Kacey Kim on 7/22/25.
//

import SwiftUI

struct CurrentQuantityView: View {
    let quantity: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 200, height: 200)
                Text(quantity)
                    .foregroundStyle(.white)
                    .font(.system(size: 48, weight: .bold))
            }
        }
    }
}

#Preview {
    CurrentQuantityView(quantity: "20", color: .overdue, onTap: {})
}
