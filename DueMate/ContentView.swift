//
//  ContentView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        NavigationStack{
            VStack {
                
                NavigationLink(destination: ChoreCreateView()){
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundStyle(.black)
                }
                Button(action: {
                    isSheetPresented = true
                }){
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundStyle(.black)
                }
                .sheet(isPresented: $isSheetPresented){
                    ChoreCreateView()
                        .presentationDetents([.medium, .large])
                }
                
                
            }
            .padding()
        }
        
    }
}

#Preview {
    ContentView()
}
