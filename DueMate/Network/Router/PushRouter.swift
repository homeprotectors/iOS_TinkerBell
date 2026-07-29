//
//  PushRouter.swift
//  DueMate
//
//  Created by Kacey Kim on 3/7/26.
//

import Alamofire
import Foundation

enum PushRouter: BaseRouter {
    case register(body: RegisterPushTokenRequest)
    case current(pushToken: String)
    case updateEnabled(body: UpdatePushTokenEnabledRequest)
    case delete(id: Int)
    
    var path: String {
        switch self {
        case .register:
            return "/push-tokens"
        case .current:
            return "/push-tokens/me"
        case .updateEnabled:
            return "/push-tokens/me/enabled"
        case .delete(let id):
            return "/push-tokens/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .register:
            return .post
        case .current:
            return .get
        case .updateEnabled:
            return .patch
        case .delete:
            return .delete
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .current(let pushToken):
            return [URLQueryItem(name: "pushToken", value: pushToken)]
        case .register, .updateEnabled, .delete:
            return []
        }
    }
    
    var body: Encodable? {
        switch self {
        case .register(let body):
            return body
        case .updateEnabled(let body):
            return body
        case .current:
            return nil
        case .delete:
            return nil
        }
    }
}
