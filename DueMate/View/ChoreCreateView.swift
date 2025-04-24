//
//  ChoreCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI



struct ChoreCreateView: View {
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var title: String = ""
    @State private var cycle: String = ""
    @State private var alert = "없음"
    @State private var showPicker = false
    
    let alertOptions = ["없음", "당일 (9am)","하루 전(9am)","이틀 전(9am)"]
    
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("Add New Chore")
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
            
            
            HStack{
                Text("주기").font(.system(size: 20))
                Spacer()
                TextField("1-365", text: $cycle)
                    .font(.system(size: 20))
                    .fixedSize()
                    .frame(width: 100, height: 40)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                Text("일")
                
            }
            HStack{
                Text("알람").font(.system(size: 20))
                Spacer()
                Picker("Select", selection: $alert){
                    ForEach(alertOptions, id:\.self){
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.gray)
                
                Button(action:{
                    showPicker = true
                }){
                    Text("\(alert)")
                }.sheet(isPresented: $showPicker){
                    AlertSheet(alert: $alert)
                }
                .tint(.gray)
                
            }
            Spacer()
            Button(action:{}){
                Text("생성")
                    .font(.system(size: 20))
                
            }
            .frame(width: 100)
            .padding()
            .foregroundColor(.white)
            .background(.black)
            .cornerRadius(35)
            
            
            
            
            
            Spacer()
        }
        .padding(30)
    }
    
}

#Preview {
    CreateView()
}
