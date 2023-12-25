//
//  MultiPartFormDataParameterEncoding.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/4/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public struct MultiPartFormDataParameterEncoding: FilesAndParameterEncoder {
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters?, files: Files?) throws {
        do {
            let boundary =  "Boundary-\(UUID().uuidString)"
            
            var body: Data = Data()
            
            if let parameters = parameters {
                for (key, value) in parameters {
                    try body.appendString("--\(boundary)\r\n")
                    try body.appendString("Content-Disposition:form-data; name=\"\(String(describing: key))\"\r\n\r\n")
                    
                    if let keyBool = value as? Bool, keyBool {
                        try body.appendString("True\r\n")
                    } else if let keyBool = value as? Bool, !keyBool {
                        try body.appendString("False\r\n")
                    } else {
                        try body.appendString("\(String(describing: value))\r\n")
                    }
                }
            }
            
            if let files = files {
                for file in files {
                    try body.appendString("--\(boundary)\r\n")
                    try body.appendString("Content-Disposition: form-data; name=\"\(file.key)\"; filename=\"\(file.name)\"\r\n")
                    try body.appendString("Content-Type: \"\(file.type)\"\r\n\r\n")
                    body.append(file.data ?? Data())
                    try body.appendString("\r\n")
                }
            }
            
            try body.appendString("--".appending(boundary.appending("--")))
            
            urlRequest.httpBody = body
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingMultiPartFormDataFailed
        }
    }
}
