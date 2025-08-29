//
//  BillRouter.swift
//  DueMate
//
//  Created by Kacey Kim on 8/22/25.
//

import Foundation
import Alamofire

enum BillRouter: BaseRouter {
    case getItems
    case create(body: CreateBillRequest)
    case delete(id: Int)
    
    
    
    var path: String {
        switch self {
        case .getItems, .create:
            return "/bills"
        case .delete(let id):
            return "/bills/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getItems: return .get
        case .create: return .post
        case .delete: return .delete
        
        }
    }
    
    var body: (any Encodable)? {
        switch self {
        case .create(let body):
            return body
        default:
            return nil
        }
    }
    
   
}
