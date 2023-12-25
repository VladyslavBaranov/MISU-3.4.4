//
//  NetErrorModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/31/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct HandledErrorModel {
    var statusCode: Int
    var message: String
    
    init(statusCode sc: Int = -1, message ms: String = "Error...") {
        statusCode = sc
        message = ms
    }
}

extension HandledErrorModel: Decodable {
    private enum Keys: String, CodingKey {
        case error = "error"
        case message = "message"
        case detail = "detail"
        case details = "details"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        message = (try? container.decode(String.self, forKey: .message)) ??
                  (try? container.decode(String.self, forKey: .error)) ??
                  (try? container.decode(String.self, forKey: .detail)) ??
                  (try? container.decode(String.self, forKey: .details)) ?? "Error ..."
        statusCode = -1
    }
}

struct ErrorModel {
    let statusCode: Int?
    let error: String
    let errorResponse: ErrorResponse?
    let infoForUser: String
    let additionalInfo: String?
    
    init(error: String, infoForUser:String, statusCode: Int? = nil, additionalInfo: String? = nil, erResp: ErrorResponse? = nil) {
        self.statusCode = statusCode
        self.error = error
        self.infoForUser = infoForUser
        self.additionalInfo = additionalInfo
        self.errorResponse = erResp
    }
    
    func getInfo() -> String {
        return errorResponse?.details ?? errorResponse?.error ?? errorResponse?.token?.first ?? errorResponse?.nonFields?.first ?? error
    }
}

struct ErrorResponse {
    let error: String?
    let image: [String]?
    let details: String?
    let tags: String?
    let token: [String]?
    let nonFields: [String]?
}

extension ErrorResponse: Decodable {
    private enum Keys: String, CodingKey {
        case error = "error"
        case image = "image"
        case details = "detail"
        case tags = "tags"
        case token = "token"
        case nonFields = "non_field_errors"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        error = try? container.decode(String.self, forKey: .error)
        image = try? container.decode([String].self, forKey: .image)
        details = try? container.decode(String.self, forKey: .details)
        tags = try? container.decode(String.self, forKey: .tags)
        token = try? container.decode([String].self, forKey: .token)
        nonFields = try? container.decode([String].self, forKey: .nonFields)
    }
}
