//
//  ChoreMainView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

struct ChoreMainView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack{
            HStack{
                Text("Chore List")
                    .font(.system(size: 40))
                Spacer()
            }
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.items) { item in
                        NavigationLink {
                            //ChoreItemView(item: item)
                            ChoreCreateView(onComplete:{
                                print("MainView: complete!!")
                                viewModel.fetchChores()
                            })
                        }label: {
                            ChoreItemView(item: item, onCheckToggled: {
                                //vm server networking
                            })
                        }
                        
                    }
                }
                
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
        }
        .onAppear {
            viewModel.fetchChores()
        }
        
    }
}

#Preview {
    ChoreMainView()
}
