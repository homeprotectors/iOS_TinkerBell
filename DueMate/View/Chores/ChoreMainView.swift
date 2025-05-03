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
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.samples) { item in
                        NavigationLink {
                            //ChoreItemView(item: item)
                            ChoreCreateView()
                        }label: {
                            ChoreItemView(item: item)
                        }
                        
                    }
                }
                
                NavigationLink(destination: ChoreCreateView()){
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundStyle(.black)
                }
                
                
                
            }
            .padding()
        }
       
        
    }
}

#Preview {
    ChoreMainView()
}
