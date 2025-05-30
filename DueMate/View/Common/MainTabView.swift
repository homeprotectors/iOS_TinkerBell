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
            NavigationStack {
                ChoreMainView()
            }
            .tabItem {
                Label("", systemImage: "house")
            }
            
            NavigationStack {
                StockCreateView()
            }
            .tabItem {
                Label("", systemImage: "cart.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
}
