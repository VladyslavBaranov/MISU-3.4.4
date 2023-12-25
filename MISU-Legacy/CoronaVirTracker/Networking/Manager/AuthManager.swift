//
//  AuthManager.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/16/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import Firebase

struct AuthManager: BaseManagerHandler {
    private let router = Router<AuthApi>()
    
    static let shared = AuthManager()
    
    private init() {}
    
    func checkUser(_ cred: CheckUserModel, completion: @escaping ResultCompletion<CheckUserModel>) {
        router.request(.checkUser(username: cred.getParamForRequest())) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func logIn(_ cred: AuthenticationModel, completion: @escaping (_ token: String?,_ error: ErrorModel?)->()) {
        print("FB LI \(cred.getParamForLoginRequest())")
        router.request(.login(userCred: cred.getParamForLoginRequest())) {
            data, response, error in
            
            if let error = error {
                completion(nil, ErrorModel(error: error.localizedDescription,
                                           infoForUser: NetworkError.requestTimeOut.localizedRaw))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: NetworkError.noData.rawValue,
                                                   infoForUser: "Server error ...",
                                                   statusCode: response.statusCode))
                        return
                    }
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(AuthenticationModel.self, from: responseData)
                        completion(apiResponse.token, nil)
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    ErrorParser(statusCode: response.statusCode, data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode, erResp: apiResponse))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
    
    func registration(authModel: AuthenticationModel, completion: @escaping (_ detail: String?,_ error: ErrorModel?)->()) {
        let parameters = authModel.getParamForRegistrationRequest()
        let route: AuthApi = authModel.isNumber ? .registerNumber(userInfo: parameters) : .registerEmail(userInfo: parameters)
        router.request(route) {
            data, response, error in
            
            if let error = error {
                completion(nil, ErrorModel(error: error.localizedDescription,
                                           infoForUser: NetworkError.requestTimeOut.localizedRaw))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: NetworkError.noData.rawValue,
                                                   infoForUser: "Server error ...",
                                                   statusCode: response.statusCode))
                        return
                    }
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(AuthenticationModel.self, from: responseData)
                        completion(apiResponse.detail, nil)
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    //ErrorParser(data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "qweqweasdasd", statusCode: response.statusCode, erResp: apiResponse))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
    
    func logout(token: String, completion: @escaping (_ success: Bool,_ error: String?)->()) {
        router.request(.logout(token: token)) {
            data, response, error in
            
            if error != nil {
                completion(false, "\(NetworkError.requestTimeOut): \(error.debugDescription) ...")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    completion(true, nil)
                    
                case .failure(let networkFailureError):
                    completion(false, networkFailureError)
                }
            }
        }
    }
}
