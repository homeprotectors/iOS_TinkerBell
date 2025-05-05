//
//  ResponseModel.swift
//  DueMate
//
//  Created by Kacey Kim on 4/29/25.
//

import Foundation


struct Response<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}


//Create Response
struct ChoreCreateResponseData: Codable {
    let id: Int
    let title: String
    let cycleDays: Int
    let reminderEnabled: Bool
    let reminderDays: Int
}

//Get chore list item
struct ChoreListItem: Codable, Identifiable {
    let id: Int
    let title: String
    let cycleDays: Int
    let nextDue: String
    let reminderEnabled: Bool
}
