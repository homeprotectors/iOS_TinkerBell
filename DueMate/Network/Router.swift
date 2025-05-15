//
//  Router.swift
//  DueMate
//
//  Created by Kacey Kim on 5/5/25.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    
    case getChoreItems
    case createChoreItem(body: CreateChoreRequest)
    case deleteChoreItem(id: Int)
    
    //baseURL
    var baseURL: URL {
        URL(string: "https://duemate.onrender.com/api")!
    }
    
    //path
    var path: String {
        switch self {
        case .getChoreItems, .createChoreItem:
            return "/chores"
        case .deleteChoreItem(let id):
            return "/chores/\(id)"
            
        }
    }
    
    //method
    var method: HTTPMethod {
        switch self {
        case .getChoreItems: return .get
        case .createChoreItem: return .post
        case .deleteChoreItem: return .delete
        }
    }
    
    //parameters
    var body: RequestBody? {
            switch self {
            case .createChoreItem(let body):
                return body
            
            default:
                return nil
            }
        }
    
    func asURLRequest() throws -> URLRequest {
        
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            return try JSONParameterEncoder.default.encode(body, into: request)
        }
        return request
    }
    
    
}

