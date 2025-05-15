//
//  ChoreDetailViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 5/15/25.
//

import SwiftUI
import Alamofire

class ChoreDetailViewModel: ObservableObject {
    @Published var historyDates: [String] = []
    @Published var title: String = ""
    @Published var cycleDays: String = ""
    
    
    func fetchHistory(for id: Int){
        //history 받아옴
        historyDates =  ["2025-04-16","2025-04-29","2025-05-01","2025-05-09","2025-05-14"]
        print("fetch history: \(historyDates)")
    }
    
    func updateChore(for id:Int){
        //서버 저장
    }
    
    func deleteChore(for id:Int){
        
    }
}
