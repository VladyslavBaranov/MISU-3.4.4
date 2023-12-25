//
//  HealthParamsEPRouter.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum HealthParamsApi {
    case sugarList(userId: Int?)
    case insulinList(userId: Int?)
    case temperatureList(userId: Int? )
    case pulseList(userId: Int? )
    case bloodOxygenList(userId: Int? )
    
    case updateSugar(params: Parameters)
    case updateInsulin(params: Parameters)
    case updateTemperature(params: Parameters)
    case updatePulse(params: Parameters)
    case updateBloodOxygen(params: Parameters)
    
    case writeList(token: String, params: Parameters)
}

extension HealthParamsApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .sugarList, .updateSugar:
            return "indicators/sugar"
        case .insulinList, .updateInsulin:
            return "indicators/insulin"
        case .temperatureList, .updateTemperature:
            return "indicators/temperature"
        case .pulseList, .updatePulse:
            return "indicators/pulse"
        case .bloodOxygenList, .updateBloodOxygen:
            return "indicators/blood_oxygen"
        case .writeList:
            return "import/indicators"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .sugarList, .insulinList, .temperatureList, .pulseList, .bloodOxygenList: return .get
        case .updateSugar, .updateInsulin, .updateTemperature,
             .updatePulse, .updateBloodOxygen, . writeList:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .sugarList, .insulinList,
             .temperatureList, .pulseList, .bloodOxygenList:
            return .request
        case .updateInsulin(let data),
             .updateSugar(let data),
             .updateTemperature(let data), .updatePulse(let data), .updateBloodOxygen(let data),
             .writeList(_, let data):
            return .requestBodyJson(bodyParameters: data)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .writeList(let token, _):
            return TypeHeaders.create(token: token)
        case .updateSugar, .updateInsulin,
             .updateTemperature, .updatePulse, .updateBloodOxygen:
            guard let token = KeychainUtils.getSharedCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        case .sugarList(let idOp), .insulinList(let idOp),
             .temperatureList(let idOp), .pulseList(let idOp), .bloodOxygenList(let idOp):
            guard let token = KeychainUtils.getSharedCurrentUserToken() else { return nil }
            var headers = TypeHeaders.create(token: token)
            if let id = idOp {
                headers.updateValue("\(id)", forKey: "id")
            }
            return headers
        }
    }
}
