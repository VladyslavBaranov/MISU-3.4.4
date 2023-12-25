//
//  OrdersManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 24.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct OrdersManager: BaseManagerHandler {
    private let router = Router<OrdersApi>()

    static let shared = OrdersManager()
    private init() {}
    
    func resendOrder(messageId: Int, completion: @escaping Success200Completion) {
        router.request(.resendOrder(params: ["id":messageId])) { data, response, error in
            handleResponse(data: data, response: response, error: error, success200Completion: completion)
        }
    }
}
