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
            let url = APIConstants.baseURL + Endpoint.chores
            
            AF.request(
                url,
                method: .get
            )
            .responseData { response in
                debugPrint("RAW response:")
                debugPrint(response)
                
                if let data = response.data {
                    print("🔵 Response string:")
                    print(String(data: data, encoding: .utf8) ?? "nil")
                }
            }
            .responseDecodable(of:ChoreListItemResponse.self){
                response in
                switch response.result {
                case .success(let result):
                    print("성공!✅ \(result.message)")
                    self.items = result.data
                case .failure(let error):
                    print("에러🚩 \(error.localizedDescription)")
                }
            }
        }
        
    }
}
