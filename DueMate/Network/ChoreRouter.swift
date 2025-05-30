//
//  ChoreRouter.swift
//  DueMate
//
//  Created by Kacey Kim on 5/28/25.
//

import Foundation
import Alamofire

enum ChoreRouter: BaseRouter {
    case getItems
    case create(body: CreateChoreRequest)
    case delete(id: Int)
    case update(id: Int, body: CreateChoreRequest)
    case complete(body: EditChoreHistoryRequest)
    case undo(body: EditChoreHistoryRequest)
    
    var path: String {
        switch self {
        case .getItems, .create:
            return "/chores"
        case .delete(let id), .update(let id,_):
            return "/chores/\(id)"
        case .complete:
            return "/chores/complete"
        case .undo:
            return "/chores/undo"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getItems: return .get
        case .create, .complete, .undo: return .post
        case .delete: return .delete
        case .update: return .put
            
        }
    }
    
    //parameters
    var body: Encodable? {
        switch self {
        case .create(let body), .update(_, let body):
            return body     //CreateChoreRequest
        case .complete(let body), .undo(let body):
            return body     //EditChoreHistoryRequest
        default:
            return nil
        }
    }
}
