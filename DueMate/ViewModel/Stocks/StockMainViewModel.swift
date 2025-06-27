//
//  StockMainViewModel.swift
//  DueMate
//
//  Created by Kacey Kim on 6/12/25.
//

import Foundation
import Alamofire
import SwiftUI

class StockMainViewModel: ObservableObject {
    @Published var shouldRefresh: Bool = false
    @Published var showToast: Bool  = false
    @Published var error: NetworkError?
    @Published var items: [StockItem] = []
    
    private let network = DefaultNetworkService.shared
    
    func fetchStocks() {
        print("STOCK LIST FETCH START")
        Task {
            do {
                let items: [StockItem] = try await network.request(StockRouter.getItems)
                await MainActor.run {
                    self.items = items
                    self.sortByDueDate()
                }
                print("🎉 Stock fetch 성공!")
            } catch {
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        ErrorHandler.shared.handle(networkError)
                    } else {
                        ErrorHandler.shared.handle(NetworkError.unknown(error))
                    }
                }
                print("💥 Stock fetch 실패!  \(error.localizedDescription)")
            }
        }
    }
    
    
    func sortByDueDate() {
        items.sort { $0.nextDue < $1.nextDue }
    }
}

