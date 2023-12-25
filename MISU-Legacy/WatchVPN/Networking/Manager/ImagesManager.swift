//
//  ImagesManager.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 10/31/19.
//  Copyright © 2019 WHAR. All rights reserved.
//
import Foundation

struct ImagesManager: BaseManagerHandler {
    private let router = Router<ImagesApi>()
    
    static let shared = ImagesManager()
    
    private init() {}
    
    func getBy(link: String,  completion: @escaping ResultCompletion<Data>) {
        router.request(.getBy(link: LinkUtils.getCleanImagePath(link: link))) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
}
