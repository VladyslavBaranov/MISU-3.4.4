//
//  CovidManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

struct CovidManager: BaseManagerHandler {
    private let router = Router<CovidApi>()
    static let shared = CovidManager()
    private init() {}
    
    func getInfo(uid: Int? = nil, _ completion: @escaping ResultCompletion<[CovidModel]>) {
        router.request(.getInfo(uid: uid)) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
            //handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
    
    func update(model: CovidModel, _ completion: @escaping ResultCompletion<CovidModel>) {
        router.request(.update(params: model.encode())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
            //handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
    
    func deleteVaccine(model: VaccineModel, _ completion: @escaping Success200Completion) {
        router.request(.deleteVaccine(params: model.encodeForDelete())) { data, response, error in
            handleResponse(data: data, response: response, error: error, success200Completion: completion)
            //handleResponse(data: data, response: response, error: error, failureCompletion: debugFailureHandleCompletion, success200Completion: completion)
        }
    }
}

