//
//  ParameterEncoding.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/2/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public typealias Parameters = [String:Any]
public typealias Files = [FileModel]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public protocol FilesAndParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters?, files: Files?) throws
}
