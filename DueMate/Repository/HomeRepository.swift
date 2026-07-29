//
//  HomeRepository.swift
//  DueMate
//
//  Created by Codex on 5/15/26.
//

import Foundation

actor HomeRepository {
    static let shared = HomeRepository()
    
    private let network: any NetworkService
    
    init(network: any NetworkService = DefaultNetworkService.shared) {
        self.network = network
    }
    
    func fetchHomeSections() async throws -> [HomeSection] {
        let response: HomeSectionsData = try await network.request(ChoreRouter.getHome)
        
        let rawSections = [
            HomeSection(title: "이번주 할 일", list: response.sections.thisWeek.items),
            HomeSection(title: "다음주 할 일", list: response.sections.nextWeek.items),
            HomeSection(title: "이번달 할 일", list: response.sections.thisMonth.items),
            HomeSection(title: "다음달 할 일", list: response.sections.nextMonth.items)
        ]
        
        return rawSections.filter { !$0.list.isEmpty }
    }
    
    func completeChore(id: Int, doneDate: String) async throws {
        try await network.requestWithoutResponse(
            ChoreRouter.complete(
                body: CompleteChoreRequest(
                    choreId: id,
                    doneDate: doneDate
                )
            )
        )
    }
}
