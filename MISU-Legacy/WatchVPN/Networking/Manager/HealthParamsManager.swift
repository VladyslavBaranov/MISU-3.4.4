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
    
    func writeListHParams(token: String, model: ListHParameterModel, completion: @escaping ResultCompletion<Bool>) {
        router.request(.writeList(token: token, params: model.encodeForRequest())) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func newValueHealthParam(model: HealthParameterModel? = nil, value: Float = 0, type: HealthParamsEnum, completion: @escaping ResultCompletion<HealthParameterModel>) {
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
            }
        }()
        
        router.request(api) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
}
