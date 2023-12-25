//
//  NewsManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct NewsManager: BaseManagerHandler {
    private let router = Router<NewsApi>()
    
    static let shared = NewsManager()
    private init() {}
    
    func getAllNews(completion: @escaping ResultCompletion<[NewModel]>) {
        router.request(.getAllNews) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getPaginNews(newModel: NewPaginatedModel, completion: @escaping ResultCompletion<NewPaginatedModel>) {
        router.request(.getPaginatedNews(urlParams: newModel.nextPageURLParams(), headerParams: newModel.encode())) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
}

