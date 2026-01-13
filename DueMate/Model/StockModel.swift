//
//  StockModel.swift
//  DueMate
//
//  Created by Kacey Kim on 11/8/25.
//

import Foundation

struct CreateStockRequest: Codable {
    let name: String
    let updatedQuantity: Int
    let unitDays: Int
    let unitQuantity: Int
}

struct CreateStockResponse: Codable {
    let id: Int
    let name: String
    let unitDays: Int
    let unitQuantity: Int
    let updatedQuantity: Int
}

struct UpdateStockRequest: Codable {
    let name: String?
    let unitQuantity: Int?
    let unitDays: Int?
    let updatedQuantity: Int?
}

struct UpdateQuantityRequest: Codable {
    let updatedQuantity: Int
}

struct StockItem: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let unitDays: Int   //며칠에
    let unitQuantity: Int //몇개
    var currentQuantity: Int
    let remainingDays: Int
}

struct StockItemTemp: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let unitDays: Int   //며칠에
    let unitQuantity: Int //몇개
    var updatedQuantity: Int
}

