//
//  ChoreData.swift
//  DueMate
//
//  Created by Kacey Kim on 4/29/25.
//

import Foundation

//Create Request Body
struct CreateChoreRequest: Codable {
    let title: String
    let cycleDays: Int
    let startDate: String  // "yyyy-MM-dd"
    let reminderEnabled: Bool
    let reminderDays: Int
}

//Create Respons
struct ChoreCreateResponse: Decodable {
    let success: Bool
    let message: String
    let data: ChoreCreateResponseData
}

struct ChoreCreateResponseData: Codable {
    let id: Int
    let title: String
    let cycleDays: Int
    let reminderEnabled: Bool
    let reminderDays: Int
}


struct ChoreListItemResponse: Codable {
   
}
