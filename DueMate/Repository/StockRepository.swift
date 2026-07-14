//
//  StockRepository.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Foundation

actor StockRepository {
    static let shared = StockRepository()
    
    private let network: any NetworkService
    
    init(network: any NetworkService = DefaultNetworkService.shared) {
        self.network = network
    }
    
    func fetchItems() async throws -> [StockItem] {
        try await network.request(StockRouter.getItems)
    }
    
    func createStock(from draft: StockDraft) async throws -> StockItem {
        try await network.request(
            StockRouter.create(
                body: CreateStockRequest(
                    name: draft.name,
                    updatedQuantity: draft.currentQuantity,
                    unitDays: draft.unitDays,
                    unitQuantity: draft.unitQuantity
                )
            )
        )
    }
    
    func updateStock(
        id: Int,
        name: String?,
        unitQuantity: Int?,
        unitDays: Int?,
        updatedQuantity: Int?
    ) async throws -> StockItem {
        try await network.request(
            StockRouter.update(
                id: id,
                body: UpdateStockRequest(
                    name: name,
                    unitQuantity: unitQuantity,
                    unitDays: unitDays,
                    updatedQuantity: updatedQuantity
                )
            )
        )
    }
    
    func deleteStock(id: Int) async throws {
        try await network.requestWithoutResponse(StockRouter.delete(id: id))
    }
}
