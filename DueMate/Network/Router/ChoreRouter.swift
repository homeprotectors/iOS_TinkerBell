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
    case getHome
    case create(body: CreateChoreRequest)
    case delete(id: Int)
    case update(id: Int, body: UpdateChoreRequest)
    case complete(body: EditChoreHistoryRequest)
    case undo(body: EditChoreHistoryRequest)
    case getHistory(id: Int)
    
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
        case .getHistory(let id):
            return "/chores/\(id)/history"
        case .getHome:
            return "/chores/sections"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getItems, .getHome, .getHistory: return .get
        case .create, .complete, .undo: return .post
        case .delete: return .delete
        case .update: return .put
        }
    }
    
    //parameters
    var body: Encodable? {
        switch self {
        case .create(let body):
            return body     //CreateChoreRequest
        case .update(_, let body):
            return body     //UpdateChoreRequest
        case .complete(let body), .undo(let body):
            return body     //EditChoreHistoryRequest
        default:
            return nil
        }
    }
}
