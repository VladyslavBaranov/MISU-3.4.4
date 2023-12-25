//
//  HealthParamsManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct HealthParamsManager: BaseManagerHandler {
    private let router = Router<HealthParamsApi>()
    
    static let shared = HealthParamsManager()
    
    private init() {}
    
    func getLast(uId: Int?, completion: @escaping ResultCompletion<Health4Params>) {
        router.request(.getLast(uId: uId) ) { (data, response, error) in
            //handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func calibrate(_ model: IndicatorCalibrationModel, completion: @escaping ResultCompletion<IndicatorCalibrationModel>) {
        router.request(.calibrate(params: model.encode())) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getCalibrate(completion: @escaping ResultCompletion<[IndicatorCalibrationModel]>) -> URLSessionTask? {
        return router.requestWithReturn(.getCalibrate) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getStatictic(userId: Int? = nil, type: HealthParamsEnum, range: HealthParamsEnum.StaticticRange,
                      completion: @escaping ResultCompletion<[HealthParameterModel]>) {
        router.request(.getStatictic(userId: userId, name: type.nameVorRequest, range: range.rawValue)) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
    }
    
    func temperatureTest(completion: @escaping ResultCompletion<[HealthParameterModel]>) {
        router.request(.temperatureTest) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
            /*handleResponse(data: data, response: response, error: error,
                           successHandleCompletion: debugSuccessHandleCompletion(),
                           failureCompletion: debugFailureHandleCompletion,
                           completion: completion)*/
        }
    }
    
    func writeListHParams(model: ListHParameterModel, completion: @escaping (_ success: Bool,_ error: ErrorModel?)->()) {
        //print("### \(model.encodeForRequest())")
        router.request(.writeList(params: model.encodeForRequest())) {
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
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(false, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    //ErrorParser(data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(false, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode, erResp: apiResponse))
                    } catch {
                        completion(false, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
    
    func getHealthParamsHistory(type: HealthParamsEnum, profileId: Int? = nil, completion: @escaping (_ history: [HealthParameterModel]?,_ error: ErrorModel?)->()) {
        let api: HealthParamsApi = {
            switch type {
            case .insuline:
                return .insulinList(userId: profileId)
            case .sugar:
                return .sugarList(userId: profileId)
            case .bloodOxygen:
                return .bloodOxygenList(userId: profileId)
            case .temperature:
                return .temperatureList(userId: profileId)
            case .heartBeat:
                return .pulseList(userId: profileId)
            case .pressure:
                /// DEBUG
                return .bloodOxygenList(userId: profileId)
            }
        }()
        
        router.request(api) {
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
                        let apiResponse = try JSONDecoder().decode([HealthParameterModel].self, from: responseData)
                        completion(apiResponse, nil)
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
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode, erResp: apiResponse))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
    
    func newValueHealthParam(model: HealthParameterModel? = nil, value: Float = 0, type: HealthParamsEnum, completion: @escaping (_ history: HealthParameterModel?,_ error: ErrorModel?)->()) {
        var params: Parameters = HealthParameterModel(id: -1, value: value).encodeForRequest()
        if let md = model {
            params = md.encodeForRequest()
        }
        let api: HealthParamsApi = {
            switch type {
            case .insuline:
                return .updateInsulin(params: params)
            case .sugar:
                return .updateSugar(params: params)
            case .bloodOxygen:
                return .updateBloodOxygen(params: params)
            case .temperature:
                return .updateTemperature(params: params)
            case .heartBeat:
                return .updatePulse(params: params)
            case .pressure:
                return .pulseList(userId: -1)
            }
        }()
        
        router.request(api) {
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
                        let apiResponse = try JSONDecoder().decode(HealthParameterModel.self, from: responseData)
                        completion(apiResponse, nil)
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
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode, erResp: apiResponse))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
}
