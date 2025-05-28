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
    @Published var items: [ChoreItem] = []
    
    
    
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
    
    func completeChore(_ chore: ChoreItem) async throws {
        let body = CompleteChoreRequest(
            choreId: chore.id,
            doneDate: DateFormatter.yyyyMMdd.string(from: Date())
        )
        
        try await withCheckedThrowingContinuation { continuation in
            AF.request(Router.completeChore(body: body))
                .validate()
                .response { response in
                    switch response.result {
                    case .success(_):
                        print("\(chore.title) 완료!")
                        continuation.resume(returning: ())
                    case .failure(let error):
                        print("❌ complete failed ❌")
                        continuation.resume(throwing: error)
                    }
                }
        }
        
        await fetchChores()  
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

