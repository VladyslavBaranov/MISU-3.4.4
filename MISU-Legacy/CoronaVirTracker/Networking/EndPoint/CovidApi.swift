//
//  CovidApi.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

public enum CovidApi {
    case getInfo(uid: Int?)
    case update(params: Parameters)
    case deleteVaccine(params: Parameters)
}

extension CovidApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getInfo: return "riskgroup"
        case .update: return "riskgroup/update"
        case .deleteVaccine: return "vaccine/delete"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .update: return .put
        case .getInfo: return .get
        case .deleteVaccine: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .update(let params), .deleteVaccine(let params):
            return .requestBodyJson(bodyParameters: params)
        case .getInfo(let uid_):
            guard let uid = uid_ else { return .request }
            return .requestURL(urlParameters: ["id":uid])
        }
    }
    
    var headers: HTTPHeaders? {
        guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
        return TypeHeaders.create(token: token)
    }
}
