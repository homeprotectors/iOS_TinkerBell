//
//  MainTabView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ChoreMainView()
                .tabItem{
                    Label("Chore", systemImage: "house")
                }
        }
        
    }
}

#Preview {
    MainTabView()
}
