//
//  AlertSheet.swift
//  DueMate
//
//  Created by Kacey Kim on 4/23/25.
//

import SwiftUI

enum ReminderOptions: String, CaseIterable{
    case none = "없음"
    case theDay = "당일 (9am)"
    case oneDayBefore = "하루 전(9am)"
    case twoDaysBefore = "이틀 전(9am)"
    
    func getDays() -> Int {
        switch self {
        case .none, .theDay: return 0
        case .oneDayBefore: return 1
        case .twoDaysBefore: return 2
        }
    }
    
}



struct ReminderPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alert:ReminderOptions
    
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
                ForEach(ReminderOptions.allCases, id:\.self){
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
    ReminderPickerView(alert: .constant(.none))
}
