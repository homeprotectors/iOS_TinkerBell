//
//  ChoreMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/2/25.
//

import Foundation
import SwiftUI
import Alamofire


class ChoreMainViewModel: ObservableObject {
    @Published var shouldRefresh: Bool = false
    var items: [ChoreItem] = []

    
    
    func fetchChores() {
        print("Fetch Start ===========\n")
        
        AF.request(Router.getChoreItems)
            .responseDecodable(of:Response<[ChoreItem]>.self){
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

