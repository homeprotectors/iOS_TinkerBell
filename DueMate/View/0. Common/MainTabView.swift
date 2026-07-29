//
//  MainTabView.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var navigationState: AppNavigationState
    @StateObject private var homeStore = HomeStore.shared
    @StateObject private var choreStore = ChoreStore.shared
    @StateObject private var stockStore = StockStore.shared
    
    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $navigationState.selectedTab)
            }
            .tabItem {
                Label("Home", image: navigationState.selectedTab == .home ? "ic_home" : "ic_home_off")
                    .labelStyle(.iconOnly)
            }
            .tag(AppTab.home)
            
            NavigationStack {
                ChoreMainView()
            }
            .tabItem {
                Label("Chores", image: navigationState.selectedTab == .chores ? "ic_chore" : "ic_chore_off")
                    .labelStyle(.iconOnly)
            }
            .tag(AppTab.chores)
            
            NavigationStack {
                StockMainView()
            }
            .tabItem {
                Label("Stocks", image: navigationState.selectedTab == .stocks ? "ic_stock" : "ic_stock_off")
                    .labelStyle(.iconOnly)
            }
            .tag(AppTab.stocks)
        }
        .environmentObject(homeStore)
        .environmentObject(choreStore)
        .environmentObject(stockStore)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppNavigationState())
        .environmentObject(HomeStore.shared)
        .environmentObject(ChoreStore.shared)
        .environmentObject(StockStore.shared)
}
