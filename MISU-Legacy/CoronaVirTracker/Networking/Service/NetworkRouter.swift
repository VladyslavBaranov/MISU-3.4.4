//
//  NetworkRouter.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/3/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol NetworkRouter {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func requestWithReturn(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) -> URLSessionTask?
    func cancel()
}
