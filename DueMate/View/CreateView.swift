//
//  CreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI

enum CreateMode {
    case chore
    case bill
}

struct CreateView: View {
    @Environment(\.dismiss) private var dismiss
    let mode: CreateMode
    
    @State private var title: String = ""
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text(mode == .chore ? "New Chore" : "New Bill")
                    .font(.system(size: 20))
                
                Spacer()
                Button(action:{
                    dismiss()
                }){
                    Image(systemName: "xmark")
                        .font(.system(size: 20,weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            TextField("New Chore Title", text: $title)
                .font(.system(size: 30))
                
            
            
            Spacer()
        }
        .padding()
    }
    
}

#Preview {
    CreateView(mode: .chore)
}
