//
//  ChoreRepository.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Foundation

actor ChoreRepository {
    static let shared = ChoreRepository()
    
    private let network: any NetworkService
    
    init(network: any NetworkService = DefaultNetworkService.shared) {
        self.network = network
    }
    
    func fetchItems() async throws -> [ChoreItem] {
        let itemsResponse: [ChoreItemResponse] = try await network.request(ChoreRouter.getItems)
        return itemsResponse.map(ChoreItem.init(from:))
    }
    
    func createChore(from draft: ChoreDraft) async throws -> ChoreItem? {
        let response: ChoreItemResponse? = try await network.requestOptional(
            ChoreRouter.create(body: draft.createRequest)
        )
        return response.map(ChoreItem.init(from:))
    }
    
    func updateChore(id: Int, draft: ChoreDraft) async throws -> ChoreItem {
        let item: ChoreItemResponse = try await network.request(
            ChoreRouter.update(id: id, body: draft.updateRequest)
        )
        return ChoreItem(from: item)
    }
    
    func deleteChore(id: Int) async throws {
        try await network.requestWithoutResponse(ChoreRouter.delete(id: id))
    }
}
