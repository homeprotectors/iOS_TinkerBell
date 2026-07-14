//
//  GuestRouter.swift
//  DueMate
//
//  Created by Codex on 3/2/26.
//

import Foundation
import Alamofire

enum GuestRouter: BaseRouter {
    case register(body: RegisterGuestRequest)
    case refresh(body: RefreshGuestSessionRequest)
    case deleteAccount
    
    var requiresAuthorization: Bool {
        switch self {
        case .register, .refresh:
            return false
        case .deleteAccount:
            return true
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/guests/register"
        case .refresh:
            return LocalConfiguration.authRefreshPath
        case .deleteAccount:
            return "/account"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .register, .refresh:
            return .post
        case .deleteAccount:
            return .delete
        }
    }
    
    var body: Encodable? {
        switch self {
        case .register(let body):
            return body
        case .refresh(let body):
            return body
        case .deleteAccount:
            return nil
        }
    }
}
