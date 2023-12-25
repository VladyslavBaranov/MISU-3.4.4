//
//  AuthEPRouter.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/25/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum AuthApi {
    case checkUser(username: Parameters)
    case registerEmail(userInfo: Parameters)
    case registerNumber(userInfo: Parameters)
    case login(userCred: Parameters)
    case logout(token: String)
}

extension AuthApi: EndPointType {
    var baseURL: URL {
        switch self {
        case .checkUser, .registerNumber, .registerEmail:
            guard let url = URL(string: ServerURLs.auth) else { fatalError(NetworkError.baseURLNil.rawValue) }
            return url
        case .login, .logout:
            guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .checkUser:
            return "check"
        case .registerEmail:
            return "email/"
        case .registerNumber:
            return "mobile/"
        case .login:
            return "login"
        case .logout:
            return "logout"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .checkUser: return .post
        case .login, .logout, .registerEmail, .registerNumber: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .checkUser(let username):
            return .requestBodyJson(bodyParameters: username)
        case .registerEmail(let userInfo), .registerNumber(let userInfo):
            return .requestBodyJson(bodyParameters: userInfo)
        case .login(let userCred):
            return .requestBodyJson(bodyParameters: userCred)
        case .logout:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .logout(let token):
            return TypeHeaders.create(token: token)
        default:
            return nil
        }
    }
}
