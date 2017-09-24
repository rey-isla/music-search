//
//  URLRequest.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import Foundation

extension URLRequest {
    
    /// Convenience initializer to allow automatic URL encoding of all query items.
    init?(requestType: RequestType, scheme: String, host: String, path: String, queryItems: [URLQueryItem]) {
        
        var urlComponents = URLComponents()
        
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let encodedUrl = urlComponents.url else { return nil }
        
        self.init(url: encodedUrl)
        
        self.httpMethod = requestType.rawValue
    }
}
