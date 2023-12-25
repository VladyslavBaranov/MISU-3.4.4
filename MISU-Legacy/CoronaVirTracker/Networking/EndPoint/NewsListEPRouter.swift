//
//  NewsListEPRouter.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum NewsApi {
    case getAllNews
    case getPaginatedNews(urlParams: Parameters, headerParams: HTTPHeaders?)
}

extension NewsApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getAllNews, .getPaginatedNews:
            return "news"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getAllNews, .getPaginatedNews: return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getAllNews:
            return .request
        case .getPaginatedNews(let urlParams, _):
            return .requestURL(urlParameters: urlParams)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getPaginatedNews(_, let headerParams):
            return headerParams
        default:
            return nil
        }
    }
}
