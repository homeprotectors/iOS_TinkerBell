//
//  ChoreMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import Foundation
import SwiftUI
import Alamofire

extension ChoreMainView {
    @Observable
    class ViewModel {
        var samples: [ChoreListItem] = [
            ChoreListItem(
                    id: 1,
                    title: "Take out trash",
                    cycleDays: 3,
                    nextDueDate: "2025-05-03",
                    reminderEnabled: true
                ),
                ChoreListItem(
                    id: 2,
                    title: "Clean bathroom",
                    cycleDays: 7,
                    nextDueDate: "2025-05-05",
                    reminderEnabled: false
                )
        ]
        
        var items: [ChoreListItem] = []
        
    }
}
