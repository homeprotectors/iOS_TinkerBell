//
//  EmptyShadeLogoView.swift
//  DueMate
//
//  Created by Codex on 3/5/26.
//

import SwiftUI

struct EmptyShadeLogoView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("shadeLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .opacity(0.8)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

#Preview {
    EmptyShadeLogoView()
}
