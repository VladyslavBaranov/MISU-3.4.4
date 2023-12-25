//
//  SleepManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 30.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

struct SleepManager: BaseManagerHandler {
    private let router = Router<SleepAPI>()
    static let shared = SleepManager()
    private init() {}
    
    func getBy(model: SleepModel, _ completion: @escaping ResultCompletion<[SleepModel]>) {
        router.request(.getBy(URLparams: model.encodeForURL())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
            //handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
    
    func save(model: SleepModel, _ completion: @escaping ResultCompletion<SleepModel>) {
        router.request(.save(params: model.encode())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
            //handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
    
    func getRecommendations(_ completion: @escaping ResultCompletion<[RecommendationSleepModel]>) {
        router.request(.recommendations) { data, response, error in
            //handleResponse(data: data, response: response, error: error, completion: completion)
            handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
}


