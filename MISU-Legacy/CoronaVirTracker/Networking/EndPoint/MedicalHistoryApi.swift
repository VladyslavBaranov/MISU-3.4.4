//
//  MedicalHistoryApi.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum MedicalHistoryApi {
    case illnessHistory(id: Int?)
    case create(parameters: Parameters)
    case update(id: Int, parameters: Parameters)
    case delete(id: Int)
    
    case illnessList
    case confirmConsts
    case stateConsts
}

extension MedicalHistoryApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .illnessHistory, .create:
            return "illness"
        case .update(let id, _):
            return "illness/\(id)"
        case .delete(let id):
            return "illness/\(id)"
        case .illnessList:
            return "illness/list"
        case .confirmConsts, .stateConsts:
            return "constants"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .illnessHistory, .illnessList, .confirmConsts, .stateConsts: return .get
        case .create: return .post
        case .update: return .put
        case .delete: return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .illnessHistory(let id_):
            if let id = id_ {
                return .requestURL(urlParameters: ["profile":id])
            }
            return .request
        case .delete, .illnessList:
            return .request
        case .create(let parameters), .update(_, let parameters):
            return .requestBodyJson(bodyParameters: parameters)
        case .stateConsts:
            return .requestURL(urlParameters: ConstantsEnum.state.pathNameParam)
        case .confirmConsts:
            return .requestURL(urlParameters: ConstantsEnum.confirmed.pathNameParam)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .illnessHistory, .create, .update, .delete:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil}
            return TypeHeaders.create(token: token)
        default:
            return nil
        }
    }
}
