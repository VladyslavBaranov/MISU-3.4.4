//
//  ListDHManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct ListDHManager: BaseManagerHandler {
    private let router = Router<ListDHApi>()
    static let shared = ListDHManager()
    private init() {}
    
    func getAllHospitals(onlyOneHOspital hosp: HospitalModel? = nil, one: Bool, completion: @escaping (_ usersList: [HospitalModel]?,_ error: HandledErrorModel?)->()) {
        if one, hosp?.id == nil {
            completion(nil, nil)
            return
        }
        router.request(.getAllHospitals(id: hosp?.id)) { data, response, error in
            handleResponse(data: data, response: response, error: error, failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
    
    func getAllDoctors(onlyOneDoctor doctor: UserModel? = nil, one: Bool, completion: @escaping (_ usersList: [UserModel]?,_ error: HandledErrorModel?)->()) {
        if one, doctor?.doctor?.id == nil {
            completion(nil, nil)
            return
        }
        router.request(.getAllDoctors(id: doctor?.doctor?.id)) { data, response, error in
            handleResponse(data: data, response: response, error: error, successHandleCompletion: {
                (data, response) -> (result:  [UserModel]?, error: HandledErrorModel?) in
                guard let responseData = data else {
                    return (nil, .init(statusCode: response.statusCode, message: NetworkError.noData.rawValue))
                }
                
                do {
                    //ErrorParser(data: responseData)
                    let apiResponse = try JSONDecoder().decode([DoctorModel].self, from: responseData)
                    var userMod: [UserModel] = []
                    apiResponse.forEach { doc in
                        var usMd = UserModel(id: doc.id)
                        usMd.doctor = doc
                        usMd.userType = UserTypeEnum.determine(usMd)
                        userMod.append(usMd)
                    }
                    return (userMod, nil)
                } catch {
                    return (nil, .init(statusCode: response.statusCode, message: NetworkError.unableToDecode.localizedRaw))
                }
            }, completion: completion)
        }
    }
    
    func getGetPatientsOfCurrentDoctor(token: String, completion: @escaping (_ usersList: [UserModel]?,_ error: ErrorModel?)->()) {
        router.request(.getGetPatientsOfCurrentDoctor(token: token)) {
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
                        let apiResponse = try JSONDecoder().decode([UserCardModel].self, from: responseData)
                        var userMod: [UserModel] = []
                        apiResponse.forEach { profile in
                            var usMd = UserModel(id: profile.id)
                            usMd.profile = profile
                            userMod.append(usMd)
                        }
                        completion(userMod, nil)
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
    
    func getProfile(id: Int, completion: @escaping (_ usersList: [UserModel]?,_ error: ErrorModel?)->()) -> URLSessionTask? {
        return router.requestWithReturn(.getPatient(id: id)) {
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
                        let apiResponse = try JSONDecoder().decode([UserCardModel].self, from: responseData)
                        var userMod: [UserModel] = []
                        apiResponse.forEach { profile in
                            var usMd = UserModel(id: profile.id)
                            usMd.profile = profile
                            userMod.append(usMd)
                        }
                        completion(userMod, nil)
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

