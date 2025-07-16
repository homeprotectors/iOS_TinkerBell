//
//  AlertSheet.swift
//  DueMate
//
//  Created by Kacey Kim on 4/23/25.
//

import SwiftUI

enum ReminderOptions: String, CaseIterable{
    case none = "없음"
    case theDay = "당일"
    case oneDayBefore = "하루 전"
    case twoDaysBefore = "이틀 전"
    case oneWeekBefore = "일주일 전"
    case twoWeeksBefore = "이주일 전"
    
    func getDays() -> Int? {
        switch self {
        case .none: return nil
        case .theDay: return 0
        case .oneDayBefore: return 1
        case .twoDaysBefore: return 2
        case .oneWeekBefore: return 7
        case .twoWeeksBefore: return 14
        }
    }
    
}



struct ReminderPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alert:ReminderOptions
    
    var body: some View {
        ZStack{
            Color.white.opacity(0.6).blur(radius: 1)
                .ignoresSafeArea()
            VStack{
                Picker("Select", selection: $alert){
                    ForEach(ReminderOptions.allCases, id:\.self){
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.wheel)
                .overlay(
                    Button(action:{
                        self.dismiss()
                    }){
                        Image(systemName: "checkmark")
                            .font(.system(size: 25,weight: .bold))
                            .foregroundColor(.black)
                    }, alignment: .topTrailing
                )
                Text("알람 전송 시각 9am").foregroundColor(.gray)
                
            }
            .padding(30)
            .presentationDetents([.height(300)])
        }
        
    }
}

#Preview {
    ReminderPickerView(alert: .constant(.none))
}
