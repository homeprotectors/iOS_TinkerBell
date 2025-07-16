//
//  ReminderField.swift
//  DueMate
//
//  Created by Kacey Kim on 7/15/25.
//

import SwiftUI

struct ReminderField: View {
    @Binding var selectedReminder: ReminderOptions
    @State private var showReminderPicker = false
    var foregroundColor: Color = .gray
    var underlineHeight: CGFloat = 1
    
    
    var body: some View {
        Button {
                    showReminderPicker = true
                } label: {
                    VStack(spacing: 6) {
                        HStack {
                            Text(selectedReminder.rawValue)
                                .foregroundColor(selectedReminder == .none ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(foregroundColor)
                        }
                        .background(Color.clear)
                        Rectangle()
                            .fill(foregroundColor)
                            .frame(height: underlineHeight)
                    }
                }
                .sheet(isPresented: $showReminderPicker) {
                    ReminderPickerView(alert: $selectedReminder)
                }
    }
}

#Preview {
    ReminderField(selectedReminder: .constant(.none))
}
