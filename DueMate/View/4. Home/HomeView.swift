//
//  HomeView.swift
//  DueMate
//
//  Created by Kacey Kim on 9/16/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical,20)
                
                ScrollView {
                    listView
                }
            }
            .padding(12)
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
        
    }
    
    private var listView: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.homeList) { section in
                //섹션 헤더
                if section.id == 0 {
                    HStack {
                        Text("이번주 할 일")
                            .font(.listText)
                        Spacer()
                        Text(Date().toHomeToday())
                            .font(.listText)
                    }
                } else {
                    Text("나중에 할 일")
                        .font(.listText)
                }
                
                
                //내부 리스트
                LazyVStack {
                    ForEach(section.list) { item in
                        HomeItemView(item: item, onLongPress: { frame in
                            viewModel.selectItem(item, frame: frame)
                        })
                        
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
}
