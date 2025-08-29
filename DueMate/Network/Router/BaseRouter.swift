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
        URL(string: "http://ec2-15-164-220-42.ap-northeast-2.compute.amazonaws.com:8080/api")!
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

