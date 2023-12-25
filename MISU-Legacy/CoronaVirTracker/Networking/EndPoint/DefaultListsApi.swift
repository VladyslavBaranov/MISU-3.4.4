//
//  DefaultListsApi.swift
//  CoronaVirTracker
//
//  Created by WH ak on 20.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum DefaultListsApi {
    case getSymptoms
    case getPositions
    case getConstant(_ type: ConstantsEnum)
}

extension DefaultListsApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getSymptoms:
            return "symptoms"
        case .getPositions:
            return "positions"
        case .getConstant:
            return "constants"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .getConstant(let type):
            return .requestURL(urlParameters: type.pathNameParam)
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        var h = HTTPHeaders()
        if let token = KeychainUtils.getCurrentUserToken() {
            h = TypeHeaders.create(token: token)
        }
        if let lCode = Locale.current.languageCode {
            h.updateValue(lCode, forKey: "Accept-Language")
        }
        
        return h.count == 0 ? nil : h
    }
}
