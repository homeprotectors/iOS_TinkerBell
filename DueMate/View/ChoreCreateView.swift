//
//  ChoreCreateView.swift
//  DueMate
//
//  Created by Kacey Kim on 4/21/25.
//

import SwiftUI



struct ChoreCreateView: View {
    
    @State private var title: String = ""
    @State private var cycle: String = ""
    @State private var alert = "없음"
    @State private var showPicker = false
    
    let alertOptions = ["없음", "당일 (9am)","하루 전(9am)","이틀 전(9am)"]
    
    // Form Validation
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !cycle.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Title
            Text("New Chore")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Title Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("New Chore Title", text: $title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            // Cycle Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Cycle")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("1-365", text: $cycle)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Text("일")
                        .foregroundColor(.gray)
                }
            }
            
            // Alert Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Reminder")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showPicker = true
                }) {
                    HStack {
                        Text(alert)
                            .foregroundColor(alert == "없음" ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showPicker) {
                    AlertSheet(alert: $alert)
                }
            }
            
            // Submit Button
            Button(action: {
                
            }) {
                Text("생성")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.black : Color.gray.opacity(0.4))
                    .foregroundColor(isFormValid ? .white : .gray)
                    .cornerRadius(16)
            }
            .disabled(!isFormValid)
            .padding(.top, 12)
            
            Spacer()
        }
        .padding(24)
        .background(Color(.systemBackground))
    }
    
}

#Preview {
    ChoreCreateView()
}
