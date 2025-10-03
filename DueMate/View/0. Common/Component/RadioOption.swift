//
//  RadioOption.swift
//  DueMate
//
//  Created by Kacey Kim on 9/30/25.
//

import SwiftUI

struct RadioOption: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let value: String
    let onImage: String
    let offImage: String
    
}
