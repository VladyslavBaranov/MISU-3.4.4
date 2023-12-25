//
//  HospitalsManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 03.01.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

struct HospitalsManager: BaseManagerHandler {
    private let router = Router<HospitalsAPI>()
    static let shared = HospitalsManager()
    private init() {}
    
    func search(_ listModel: HospitalListModelT, completion: @escaping ResultCompletion<HospitalListModelT>) {
        router.request(.search(params: listModel.searchBodyParams(), urlParams: listModel.searchUrlParams())) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getHospital(by id: Int, completion: @escaping ResultCompletion<[HospitalModel]>) {
        router.request(.getHospital(id: id)) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getAllHospitals(_ listModel: HospitalListModelT, completion: @escaping ResultCompletion<HospitalListModelT>) {
        router.request(.getAllHospitals(urlParams: listModel.nextPageURLParams())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getCities(listModel: CitiesListModel, completion: @escaping ResultCompletion<CitiesListModel>) {
        router.request(.getAllCities(urlParams: listModel.nextPageURLParams())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
}

