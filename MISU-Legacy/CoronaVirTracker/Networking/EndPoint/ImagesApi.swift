//
//  ImagesEPRouter.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 10/30/19.
//  Copyright © 2019 WHAR. All rights reserved.
//
import Foundation

public enum ImagesApi {
    case getBy(link: String)
    //case setImage(image: Files)
}

extension ImagesApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.base) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getBy(let link):
            return link
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getBy: return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getBy:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
