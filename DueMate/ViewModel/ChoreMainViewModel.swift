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
                    nextDue: "2025-05-03",
                    reminderEnabled: true
                ),
                ChoreListItem(
                    id: 2,
                    title: "Clean bathroom",
                    cycleDays: 7,
                    nextDue: "2025-05-05",
                    reminderEnabled: false
                )
        ]
        
        var items: [ChoreListItem] = []
        var isRemainderOn = false
        
        
        func fetchChores() {
            print("Fetch Start ===========\n")
            
            AF.request(Router.getChoreItems)
                .responseDecodable(of:Response<[ChoreListItem]>.self){
                response in
                switch response.result {
                case .success(let result):
                    print("성공!✅ \(result.message)")
                    self.items = result.data ?? []
                    self.sortByDueDate()
                case .failure(let error):
                    print("에러🚩 \(error.localizedDescription)")
                }
            }
        }
        
        func sortByDueDate() {
            items.sort { (item1, item2) -> Bool in
                return item1.nextDue < item2.nextDue
            }
        }
        
        func getListColor(due: String) -> Color {
            guard let remainDays = due.daysFromToday() else {
                return ListColor.normal
            }
            switch remainDays {
            case ...0:
                return ListColor.overdue
            case 1...3:
                return ListColor.warning
            default:
                return ListColor.normal
            }
        }
        
    }
}
