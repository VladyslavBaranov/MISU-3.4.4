//
//  PushNotificationEpRouter.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum PushNotificationReqApi {
    case setDevice(parameters: Parameters)
}

extension PushNotificationReqApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .setDevice:
            return "device"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .setDevice: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .setDevice(let parameters):
            return .requestBodyJson(bodyParameters: parameters)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .setDevice:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        }
    }
}
