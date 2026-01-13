//
//  HomeView.swift
//  DueMate
//
//  Created by Kacey Kim on 9/16/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isExpanded = false
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0) {
                Image("logo")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 12)
                
                listView
            }
            .blur(radius: viewModel.selectedItem != nil ? 10 : 0)
            
            //선택시 포커스뷰
            if let item = viewModel.selectedItem {
                ZStack {
                    Color.black.opacity(0.01)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.clearSelectedItem()
                        }
                    
                    FocusView(
                        item: item,
                        dragOffset: viewModel.dragOffset,
                        onDragChanged: { translation in
                            viewModel.dragOffset = translation
                        },
                        onDragEnded: { translation in
                            viewModel.dragEnded(translation)
                        },
                        onDismiss: { viewModel.clearSelectedItem()
                        }
                    )
                    .shadow(radius: 5)
                    .position(
                        x: viewModel.selectedItemFrame.midX,
                        y: viewModel.selectedItemFrame.midY - 50
                    )
                }
            }
        }
        .onAppear {
            viewModel.fetchHome()
        }
        .withErrorToast()
    }
    
   
     
    private var listView: some View {
        List {
            ForEach(viewModel.homeList) { section in
                Section {
                    ForEach(section.list) { item in
                        Group {
                            if item.shoppingContainer {
                                HomeExpandableItemView(item: item, shoppingList: item.shoppingItems ?? [], onLongPress: { frame in
                                    viewModel.selectItem(item, frame: frame)
                                },isExpanded: $isExpanded)
                                .onTapGesture {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                    
                                }
                            } else {
                                HomeItemView(item: item, onLongPress: { frame in
                                    viewModel.selectItem(item, frame: frame)
                                })
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    SectionHeaderView(title: section.title)
                }
            }
        }
        
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
        .environment(\.defaultMinListHeaderHeight, 0)
    }
}


#Preview {
    HomeView()
}
