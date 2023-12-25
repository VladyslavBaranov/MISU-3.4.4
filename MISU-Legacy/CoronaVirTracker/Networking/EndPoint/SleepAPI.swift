//
//  SleepAPI.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 30.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

public enum SleepAPI {
    case getBy(URLparams: Parameters)
    case save(params: Parameters)
    case recommendations
}

extension SleepAPI: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getBy: return "dream"
        case .save: return "dream"
        case .recommendations: return "dream/recommendation"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getBy, .recommendations: return .get
        case .save: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .save(let params):
            return .requestBodyJson(bodyParameters: params)
        case .getBy(let URLparams):
            return .requestURL(urlParameters: URLparams)
        case .recommendations:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
        return TypeHeaders.create(token: token)
    }
}
