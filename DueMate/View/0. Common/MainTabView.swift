//
//  MainTabView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ChoreMainView()
            }
            .tabItem {
                Image(selectedTab == 0 ? "ic_home" : "ic_home_off")
            }
            .tag(0)
            
            NavigationStack {
                ChoreMainView()
            }
            .tabItem {
                Image(selectedTab == 1 ? "ic_chore" : "ic_chore_off")
            }
            .tag(1)
            
            NavigationStack {
                StockMainView()
            }
            .tabItem {
                Image(selectedTab == 2 ? "ic_stock" : "ic_stock_off")
            }
            .tag(2)
            
            NavigationStack {
                BillMainView()
            }
            .tabItem {
                Image(selectedTab == 3 ? "ic_bill" : "ic_bill_off")
            }
            .tag(3)
        }
    }
}

#Preview {
    MainTabView()
}
