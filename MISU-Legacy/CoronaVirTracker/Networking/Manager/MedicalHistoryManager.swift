//
//  MedicalHistoryManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct MedicalHistoryManager {
    private let router = Router<MedicalHistoryApi>()
    static let shared = MedicalHistoryManager()
    private init() {}
    
    func illnessHistory(id: Int? = nil, completion: @escaping (_ list: [IllnessModel]?,_ error: ErrorModel?)->()) {
        router.request(.illnessHistory(id: id)) {
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
                        let apiResponse = try JSONDecoder().decode([IllnessModel].self, from: responseData)
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
    
    func createIllness(_ illness: IllnessModel, completion: @escaping (_ list: IllnessModel?,_ error: ErrorModel?)->()) {
        router.request(.create(parameters: illness.getParamsDict())) {
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
                        ErrorParser(statusCode: response.statusCode, data: responseData)
                        let apiResponse = try JSONDecoder().decode(IllnessModel.self, from: responseData)
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
    
    func updateIllness(_ illness: IllnessModel, completion: @escaping (_ list: IllnessModel?,_ error: ErrorModel?)->()) {
        router.request(.update(id: illness.id, parameters: illness.getParamsDict())) {
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
                        let apiResponse = try JSONDecoder().decode(IllnessModel.self, from: responseData)
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
    
    func deleteIllness(id: Int, completion: @escaping (_ success: Bool,_ error: ErrorModel?)->()) {
        router.request(.delete(id: id)) {
            data, response, error in
            
            if let error = error {
                completion(false, ErrorModel(error: error.localizedDescription,
                                           infoForUser: NetworkError.requestTimeOut.localizedRaw))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    completion(true, nil)
                    return
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(false, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    ErrorParser(statusCode: response.statusCode, data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(false, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode))
                    } catch {
                        completion(false, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
    
    func confirmConsts(completion: @escaping (_ list: [ConstantsModel]?,_ error: ErrorModel?)->()) {
        router.request(.confirmConsts) {
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
                        let apiResponse = try JSONDecoder().decode([ConstantsModel].self, from: responseData)
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
    
    func stateConsts(completion: @escaping (_ list: [ConstantsModel]?,_ error: ErrorModel?)->()) {
        router.request(.stateConsts) {
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
                        let apiResponse = try JSONDecoder().decode([ConstantsModel].self, from: responseData)
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
    
    func illnessList(completion: @escaping (_ usersList: [IllnessListItemModel]?,_ error: ErrorModel?)->()) {
        router.request(.illnessList) {
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
                        let apiResponse = try JSONDecoder().decode([IllnessListItemModel].self, from: responseData)
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
