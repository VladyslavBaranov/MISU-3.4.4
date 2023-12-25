//
//  UsersListEPRouter.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/1/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum UsersListApi {
    case getAllUsers(id: Int?)
}

extension UsersListApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getAllUsers(let uId):
            if let id = uId { return "users/\(id)" }
            return "users"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getAllUsers: return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getAllUsers:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
        return TypeHeaders.create(token: token)
    }
}
