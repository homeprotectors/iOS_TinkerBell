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

struct SectionItem<T: Decodable>: Decodable, Identifiable {
    let id =  UUID()
    let header: String
    let list: [T]
}
