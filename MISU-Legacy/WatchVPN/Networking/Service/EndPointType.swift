//
//  EndPointType.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/2/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}


