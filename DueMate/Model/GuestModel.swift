//
//  GuestModel.swift
//  DueMate
//
//  Created by Kacey Kim on 3/2/26.
//

import Foundation

struct RegisterGuestRequest: Codable {
    let installId: String
}

struct RefreshGuestSessionRequest: Codable {
    let refreshToken: String
}

struct GuestAuthTokens: Codable {
    let userId: String?
    let accessToken: String
    let refreshToken: String?
    let tokenType: String?
    let expiresIn: Int?
}

struct RegisterGuestData: Codable {
    let userId: String
    let tokens: GuestAuthTokens
}

struct RefreshGuestData: Codable {
    let tokens: GuestAuthTokens
    
    private enum CodingKeys: String, CodingKey {
        case tokens
    }
    
    init(tokens: GuestAuthTokens) {
        self.tokens = tokens
    }
    
    init(from decoder: Decoder) throws {
        if let directTokens = try? GuestAuthTokens(from: decoder) {
            self.tokens = directTokens
            return
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tokens = try container.decode(GuestAuthTokens.self, forKey: .tokens)
    }
}
