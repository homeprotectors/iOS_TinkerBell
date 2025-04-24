//
//  AlertSheet.swift
//  DueMate
//
//  Created by Kacey Kim on 4/23/25.
//

import SwiftUI

struct AlertSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alert:String
    let alertOptions = ["없음", "당일 (9am)","하루 전(9am)","이틀 전(9am)"]
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button(action:{
                    self.dismiss()
                }){
                    Image(systemName: "xmark")
                        .font(.system(size: 20,weight: .bold))
                        .foregroundColor(.black)
                }
            }
            Picker("Select", selection: $alert){
                ForEach(alertOptions, id:\.self){
                    Text($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
        }
        .padding(30)
        .presentationDetents([.height(300)])
    }
}

#Preview {
    AlertSheet(alert: .constant("없음"))
}
