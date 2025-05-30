//
//  Router.swift
//  DueMate
//
//  Created by Kacey Kim on 5/5/25.
//

import Alamofire
import Foundation

protocol BaseRouter: URLRequestConvertible {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
}


extension BaseRouter {
    
    //baseURL
    var baseURL: URL {
        URL(string: "https://duemate.onrender.com/api")!
    }
    
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.method = method
        if let body = body {
            return try JSONParameterEncoder.default.encode(body, into: request)
        }
        
        return request
    }
    
    
}

