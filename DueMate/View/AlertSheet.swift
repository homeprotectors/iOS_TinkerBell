//
//  AlertSheet.swift
//  DueMate
//
//  Created by Kacey Kim on 4/23/25.
//

import SwiftUI

enum alertOptions: String, CaseIterable{
    case none = "없음"
    case theDay = "당일 (9am)"
    case oneDayBefore = "하루 전(9am)"
    case twoDaysBefore = "이틀 전(9am)"
    
}


struct AlertSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alert:alertOptions
    
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
                ForEach(alertOptions.allCases, id:\.self){
                    Text($0.rawValue)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
        }
        .padding(30)
        .presentationDetents([.height(300)])
    }
}

#Preview {
    AlertSheet(alert: .constant(.none))
}
