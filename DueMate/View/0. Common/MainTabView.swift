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
                StockMainView()
            }
            .tabItem {
                Label("", systemImage: "cart.fill")
            }
            
            NavigationStack {
                BillMainView()
            }
            .tabItem {
                Label("", systemImage: "dollarsign.circle")
            }
            NavigationStack {
                Test()
            }
            .tabItem {
                Label("", systemImage: "dollarsign.circle")
            }
        }
    }
}

#Preview {
    MainTabView()
}
