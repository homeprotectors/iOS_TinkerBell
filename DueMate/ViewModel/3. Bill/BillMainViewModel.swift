//
//  BillMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 8/5/25.
//

import Foundation
import SwiftUI

class BillMainViewModel: ObservableObject {
    @StateObject private var viewModel = BillMainViewModel()
    @Published var items: [BillItem] = []
    
    
    func fetchBills() {
        
    }
}
