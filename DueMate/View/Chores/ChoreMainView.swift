//
//  ChoreMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

struct ChoreMainView: View {
    @StateObject private var viewModel = ChoreMainViewModel()
    
    var body: some View {
        NavigationStack{
            HStack{
                Text("HOUSEHOLD\nLIST")
                    .font(.system(size: 40, weight: .bold))
                Spacer()
                NavigationLink {
                    ChoreCreateView(onComplete:{
                        print("MainView: complete!!")
                        viewModel.fetchChores()
                    })
                }label: {
                    Image(systemName: "plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.black)
                }
                .padding()
            }
            .padding()
            .padding(.top, 30)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.items) { item in
                        NavigationLink {
                            ChoreDetailView(item: item)
                                .environmentObject(viewModel)
                        }label: {
                            ChoreItemView(item: item, color: viewModel.getListColor(due: item.nextDue), onCheckToggled: {
                                //vm server networking
                                print("checkToggeld!")
                            } )
                        }
                        .buttonStyle(.plain)
                        
                    }
                }
                
                
                
            }
            .padding()
        }
        .onAppear {
            print("main onAppear")
            viewModel.fetchChores()
        }
        .onChange(of: viewModel.shouldRefresh) {
            if viewModel.shouldRefresh {
                print("main refresh")
                viewModel.fetchChores()
                viewModel.shouldRefresh = false
            }
        }
        
    }
}

#Preview {
    ChoreMainView()
}
