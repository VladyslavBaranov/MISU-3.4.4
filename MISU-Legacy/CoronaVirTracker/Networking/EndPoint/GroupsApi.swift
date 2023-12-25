//
//  GroupsApi.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 14.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum GroupsApi {
    case getAll
    case create(parameters: Parameters)
    case update(id: Int, parameters: Parameters)
    case delete(id: Int)
    case leave
    
    case getAllInvites
    case inviteUser(parameters: Parameters)
    case replyToInvite(id: Int, parameters: Parameters)
    case deleteInvite(id: Int)
}

extension GroupsApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getAll, .create:
            return "group"
        case .update(let id, _), .delete(let id):
            return "group/\(id)"
        case .leave:
            return "group/delete"
        case .getAllInvites, .inviteUser:
            return "request"
        case .replyToInvite(let id, _), .deleteInvite(let id):
            return "request/\(id)"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getAll, .getAllInvites: return .get
        case .create, .inviteUser, .leave: return .post
        case .update, .replyToInvite: return .put
        case .delete, .deleteInvite: return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getAll, .getAllInvites, .delete, .deleteInvite, .leave:
            return .request
        case .create(let parameters), .inviteUser(let parameters),
             .replyToInvite(_, let parameters), .update(_, let parameters):
            return .requestBodyJson(bodyParameters: parameters)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getAll, .create, .update, .delete,
             .getAllInvites, .inviteUser, .replyToInvite,
             .deleteInvite, .leave:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        }
    }
}
