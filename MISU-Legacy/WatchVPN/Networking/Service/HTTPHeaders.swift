//
//  HTTPHeaders.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/6/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String:String]

class TypeHeaders {
    static func create(token: String) -> HTTPHeaders {
        return ["Authorization":"Token \(token)"]
    }
}
