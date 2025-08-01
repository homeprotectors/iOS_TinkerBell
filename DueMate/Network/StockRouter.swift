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
    case update(id: Int, body: UpdateStockRequest)
    case delete(id: Int)
    
    var path: String {
        switch self {
        case .getItems, .create:
            return "/stocks"
            
        case .delete(let id), .update(let id,_):
            return "/stocks/\(id)"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getItems: return .get
        case .create, .update: return .post
        case .delete: return .delete
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
