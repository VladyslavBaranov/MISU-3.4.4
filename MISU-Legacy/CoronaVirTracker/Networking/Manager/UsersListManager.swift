//
//  UsersListManager.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/1/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct UsersListManager: BaseManagerHandler {
    private let router = Router<UsersListApi>()
    
    static let shared = UsersListManager()
    
    private init() {}
    
    func getAllUsersReturn(id: Int? = nil, one: Bool, completion: @escaping ResultCompletion<[UserModel]>) -> URLSessionTask? {
        if id == nil && one {
            completion(nil, nil)
            return nil
        }
        return router.requestWithReturn(.getAllUsers(id: id)) {
            data, response, error in
                handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getAllUsers(id: Int? = nil, one: Bool, completion: @escaping (_ usersList: [UserModel]?,_ error: ErrorModel?)->()) {
        if id == nil && one { completion(nil, nil) }
        router.request(.getAllUsers(id: id)) {
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
                        //ErrorParser(data: responseData)
                        let apiResponse = try JSONDecoder().decode([UserModel].self, from: responseData)
                        completion(apiResponse, nil)
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
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
}

