//
//  FormDataParameterEncoding.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/4/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public struct FormDataParameterEncoding: ParameterEncoder {
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        if parameters.isEmpty {
            throw NetworkError.encodingFailed
        }
        
        var data = [String]()
        for(key, value) in parameters {
            data.append(key + "=\(value)")
        }
        let postString = data.map { String($0) }.joined(separator: "&")
        urlRequest.httpBody = postString.data(using: .utf8)
            
//        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
//            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        }
    }
}
