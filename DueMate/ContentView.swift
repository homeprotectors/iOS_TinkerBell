//
//  ContentView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        NavigationStack{
            VStack {
                
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
    ContentView()
}
