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
        }
        .onAppear {
            viewModel.fetchHome()
        }
        
    }
    
    private var listView: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach($viewModel.homeList) { $section in
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
                            viewModel.selectedItemFrame = frame
                            
                        })
                        .padding(6)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
