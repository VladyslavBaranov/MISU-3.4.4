//
//  UserEPRouter.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/16/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public enum UserApi {
    case getCurrentUser(token: String)
    
    case createProfile(token: String, profile: Parameters)
    case updateProfile(token: String, updatedProfile: Parameters, updatedFiles: Files)
    
    case createDoctor(token: String, profile: Parameters)
    case updateDoctor(token: String, updatedDoctor: Parameters, updatedFiles: Files)
    
    case updateIll(updatedIll: Parameters)
    
    case createLocation(token: String, location: Parameters)
    case updateLocation(token: String, updatedLocation: Parameters)
    
    case updateSugar(params: Parameters)
    case sugarList(userId: Int? )
    
    case updateInsulin(params: Parameters)
    case insulinList(userId: Int? )
    
    case delete
}

extension UserApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getCurrentUser:
            return "current_user"
        case .createProfile:
            return "profile/create"
        case .updateProfile:
            return "profile/update"
        case .createDoctor:
            return "doctor/create"
        case .updateDoctor:
            return "doctor/update"
        case .updateIll:
            return "ill/update"
        case .createLocation:
            return "location/create"
        case .updateLocation:
            return "location/update"
        case .sugarList, .updateSugar:
            return "sugar"
        case .insulinList, .updateInsulin:
            return "insulin"
        case .delete:
            return "user/delete"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getCurrentUser, .sugarList, .insulinList: return .get
        case .createProfile, .createDoctor, .createLocation, .updateIll,
             .updateSugar, .updateInsulin, .delete: return .post
        case .updateProfile, .updateDoctor, .updateLocation: return .put
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getCurrentUser,
             .sugarList,
             .insulinList,
             .delete:
            return .request
        case .createProfile(_, let data),
             .createDoctor(_, let data),
             .updateIll(let data),
             .createLocation(_, let data),
             .updateLocation(_, let data),
             .updateInsulin(let data),
             .updateSugar(let data):
            return .requestBodyJson(bodyParameters: data)
        case .updateProfile(_ , let updatedParams, let updatedFiles),
             .updateDoctor(_, let updatedParams, let updatedFiles):
            if updatedFiles.isEmpty { return .requestBodyJson(bodyParameters: updatedParams) }
            return .requestBodyMultiPartFormDataFiles(bodyParameters: updatedParams, files: updatedFiles)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getCurrentUser(let token),
             .createProfile(let token, _),
             .updateProfile(let token, _, _),
             .createDoctor(let token, _),
             .updateDoctor(let token, _, _),
             .createLocation(let token, _),
             .updateLocation(let token, _):
            return TypeHeaders.create(token: token)
        case .updateIll, .updateSugar, .updateInsulin, .delete:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        case .sugarList(let idOp), .insulinList(let idOp):
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            var headers = TypeHeaders.create(token: token)
            if let id = idOp {
                headers.updateValue("\(id)", forKey: "id")
            }
            return headers
        }
    }
}
