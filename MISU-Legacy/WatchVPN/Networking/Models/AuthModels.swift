//
//  AuthModels.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/31/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct CheckUserModel {
    private let username: String
    let isRegistered: Bool
    
    init(credential: String) {
        self.username = credential
        self.isRegistered = false
    }
}

extension CheckUserModel: Decodable {
    private enum Keys: String, CodingKey {
        case username = "username"
        case detail = "detail"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        isRegistered = (try? container.decode(Bool.self, forKey: .detail)) ?? false
        username = ""
    }
    
    public func getParamForRequest() -> Parameters {
        return [Keys.username.rawValue:username]
    }
}

struct LogInModel {
    let email: String
    let token: String
    
    init(email: String, token: String) {
        self.email = email
        self.token = token
    }
}

extension LogInModel: Codable {
    private enum Keys: String, CodingKey {
        case email = "email"
        case token = "token"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        token = try container.decode(String.self, forKey: .email)
        email = ""
    }
    
    public func getParamForRequest() -> Parameters {
        return [Keys.email.rawValue:email,Keys.token.rawValue:token]
    }
}

struct RegistrationModel {
    let email: String
    let detail: String?
    
    init(email: String) {
        self.email = email
        self.detail = nil
    }
}

extension RegistrationModel: Codable {
    private enum Keys: String, CodingKey {
        case email = "email"
        case detail = "detail"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        detail = try? container.decode(String.self, forKey: .detail)
        email = ""
    }
    
    public func getParamForRequest() -> Parameters {
        return [Keys.email.rawValue:email]
    }
}
