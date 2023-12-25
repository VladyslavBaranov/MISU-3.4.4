//
//  HospitalsAPI.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 03.01.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

public enum HospitalsAPI {
    case getAllHospitals(urlParams: Parameters)
    case getHospital(id: Int)
    case getAllCities(urlParams: Parameters)
    case search(params: Parameters, urlParams: Parameters)
}

extension HospitalsAPI: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getHospital(let id):
            return "hospital/\(id)"
        case .getAllHospitals:
            return "hospital"
        case .getAllCities:
            return "city_list"
        case .search:
            return "search"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getAllHospitals, .getAllCities, .getHospital: return .get
        case .search: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getHospital:
            return .request
        case .getAllHospitals(let urlParams):
            return .requestURL(urlParameters: urlParams)
        case .getAllCities(let page):
            return .requestURL(urlParameters: page)
        case .search(let bodyParams, let urlParams):
            return .requestBodyJsonUrl(bodyParameters: bodyParams, urlParameters: urlParams)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
