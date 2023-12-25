//
//  OrdersApi.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 24.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum OrdersApi {
    case resendOrder(params: Parameters)
}

extension OrdersApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .resendOrder:
            return "resend"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .resendOrder: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .resendOrder(let parameters):
            return .requestBodyJson(bodyParameters: parameters)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .resendOrder:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        }
    }
}
