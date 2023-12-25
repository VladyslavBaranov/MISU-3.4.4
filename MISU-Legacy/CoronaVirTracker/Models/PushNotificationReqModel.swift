//
//  PushNotificationReqModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct PushNotificationReqModel {
    let deviceId: String
    let type: String
    
    init(deviceId devId: String, type tp: String = "apns") {
        deviceId = devId
        type = tp
    }
}

extension PushNotificationReqModel: Codable {
    private enum Keys: String, CodingKey {
        case deviceId = "id"
        case type = "type"
    }
    
    func getParameters() -> Parameters {
        return [Keys.deviceId.rawValue:deviceId,Keys.type.rawValue:type]
    }
}
