//
//  StockRouter.swift
//  DueMate
//
//  Created by Kacey Kim on 6/27/25.
//

import Foundation
import Alamofire

enum StockRouter: BaseRouter {
    case getItems
    case create(body: CreateStockRequest)
    
    var path: String {
        switch self {
        case .getItems, .create:
            return "/stocks"
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getItems: return .get
        case .create: return .post
        }
    }
    
    var body: (any Encodable)? {
        switch self {
        case .create(let body):
            return body
        default: return nil
        }
    }
    
    
}
