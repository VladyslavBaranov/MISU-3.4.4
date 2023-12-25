//
//  ReponseHandler.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/16/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

enum Result<String> {
    case success
    case failure(String)
}

class ResponseHandler {
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 401...414: return .failure(NetworkError.authError.rawValue)
        case 415: return .failure(NetworkError.unsuppMediaType.rawValue)
        case 416...500: return .failure(NetworkError.authError.rawValue)
        case 501...599: return .failure(NetworkError.badRequest.rawValue)
        case 600: return .failure(NetworkError.outdated.rawValue)
        default: return .failure(NetworkError.failed.rawValue)
        }
    }
}
