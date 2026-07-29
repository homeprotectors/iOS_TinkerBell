//
//  HomeView.swift
//  DueMate
//
//  Created by Kacey Kim on 9/16/25.
//

import SwiftUI
import UIKit

struct HomeItemFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct HomeView: View {
    @EnvironmentObject private var homeStore: HomeStore
    @State private var itemFrames: [Int: CGRect] = [:]
    @State private var isNotificationSheetPresented = false
    @State private var selectedItem: HomeItem?
    @State private var selectedItemFrame: CGRect = .zero
    @State private var dragOffset: CGSize = .zero
    @Binding var selectedTab: AppTab
    private let feedback = UIImpactFeedbackGenerator(style: .rigid)
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0) {
                headerView
                listView
            }
            .blur(radius: selectedItem != nil ? 10 : 0)
            
            //선택시 포커스뷰
            if let item = selectedItem {
                ZStack {
                    Color.black.opacity(0.01)
                        .ignoresSafeArea()
                        .onTapGesture {
                            clearSelectedItem()
                        }
                    
                    FocusView(
                        item: item,
                        dragOffset: dragOffset,
                        onDragChanged: { translation in
                            dragOffset = translation
                        },
                        onDragEnded: { translation in
                            dragEnded(translation)
                        },
                        onDismiss: { clearSelectedItem()
                        }
                    )
                    .shadow(radius: 5)
                    .position(
                        x: selectedItemFrame.midX,
                        y: selectedItemFrame.midY - 50
                    )
                }
            }
        }
        .task {
            await homeStore.loadIfNeeded()
        }
        .sheet(isPresented: $isNotificationSheetPresented) {
            HomeSettingView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onPreferenceChange(HomeItemFramePreferenceKey.self) { frames in
            let stabilizedFrames = frames.mapValues { $0.integral }
            guard stabilizedFrames != itemFrames else { return }
            
            // Defer state update to avoid preference/layout feedback in the same frame.
            DispatchQueue.main.async {
                if self.itemFrames != stabilizedFrames {
                    self.itemFrames = stabilizedFrames
                }
            }
        }
        .withErrorToast()
    }
    
    private var headerView: some View {
        HStack{
            Text("Home")
                .font(.headerTitle)
                .foregroundColor(.accentColor)
            Spacer()
            Button {
                isNotificationSheetPresented = true
            } label: {
                Image("Logo")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("알림 설정")
                
        }
        .padding(22)
        
       
    }
    
    private var listView: some View {
        ZStack {
            if homeStore.sections.isEmpty && !homeStore.isLoading {
                EmptyShadeLogoView()
            }
            
            if homeStore.isLoading && homeStore.sections.isEmpty {
                ProgressView()
            }
            
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(homeStore.sections) { section in
                        sectionView(for: section)
                    }
                }
            }
            .refreshable {
                await homeStore.refresh()
            }
        }
    }

    private func sectionView(for section: HomeSection) -> some View {
        Section {
            VStack(spacing: 0) {
                ForEach(section.list) { item in
                    rowView(for: item)
                }
            }
            .padding(.bottom, 18)
        } header: {
            SectionHeaderView(title: section.title)
        }
    }

    @ViewBuilder
    private func rowView(for item: HomeItem) -> some View {
        if item.shoppingContainer {
            shoppingContainerRow(for: item)
        } else {
            choreRow(for: item)
        }
    }

    private func shoppingContainerRow(for item: HomeItem) -> some View {
        HomeExpandableItemView(
            item: item,
            shoppingList: item.shoppingItems ?? [],
            onDetailItemTap: { _ in
                selectedTab = .stocks
            }
        )
        .padding(.horizontal, 8)
    }

    private func choreRow(for item: HomeItem) -> some View {
        HomeItemView(
            item: item,
            onLongPress: {
                guard let frame = itemFrames[item.id] else { return }
                selectItem(item, frame: frame)
            }
        )
        .padding(.horizontal, 8)
    }
    
    private func selectItem(_ item: HomeItem, frame: CGRect) {
        
        feedback.impactOccurred()
        
        selectedItemFrame = frame
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedItem = item
        }
    }
    
    private func dragEnded(_ translation: CGSize) {
        if translation.height < -150 || translation.height > 150 {
            let itemToComplete = selectedItem
            clearSelectedItem()
            
            if let itemToComplete, !itemToComplete.shoppingContainer {
                Task {
                    await homeStore.complete(itemToComplete)
                }
            }
        } else {
            resetDragOffset()
        }
    }
    
    private func clearSelectedItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)){
            selectedItem = nil
            dragOffset = .zero
        }
    }
    
    private func resetDragOffset() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            dragOffset = .zero
        }
    }
}


#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(HomeStore.shared)
}
