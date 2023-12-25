//
//  HealthParamsEPRouter.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//
//  192.168.43.6:8000/api/indicators/temperature?date_range=1

import Foundation

public enum HealthParamsApi {
    case sugarList(userId: Int?)
    case insulinList(userId: Int?)
    case temperatureList(userId: Int?)
    case pulseList(userId: Int?)
    case bloodOxygenList(userId: Int?)
    
    case updateSugar(params: Parameters)
    case updateInsulin(params: Parameters)
    case updateTemperature(params: Parameters)
    case updatePulse(params: Parameters)
    case updateBloodOxygen(params: Parameters)
    
    case writeList(params: Parameters)
    
    case temperatureTest
    case getStatictic(userId: Int?, name: String, range: Int)
    
    case getCalibrate
    case calibrate(params: Parameters)
    case getLast(uId: Int?)
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
        case .temperatureTest:
            return "indicators/temperature"
        case .getStatictic(_, let name, _):
            return "stat/indicators/\(name)"
        case .calibrate, .getCalibrate:
            return "calibrate"
        case .getLast(let uId):
            guard let u = uId else {
                return "indicators/last"
            }
            return "indicators/last/\(u)"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .sugarList, .insulinList, .temperatureList, .pulseList, .bloodOxygenList: return .get
        case .updateSugar, .updateInsulin, .updateTemperature,
             .updatePulse, .updateBloodOxygen, .writeList, .calibrate:
            return .post
        case .temperatureTest, .getStatictic, .getCalibrate, .getLast:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .sugarList, .insulinList,
             .temperatureList, .pulseList, .bloodOxygenList, .getCalibrate, .getLast:
            return .request
        case .updateInsulin(let data),
             .updateSugar(let data),
             .updateTemperature(let data), .updatePulse(let data), .updateBloodOxygen(let data),
             .writeList(let data), .calibrate(let data):
            //print("### b \(data)")
            return .requestBodyJson(bodyParameters: data)
        case .temperatureTest:
            return .requestURL(urlParameters: ["date_range":365])
        case .getStatictic(_, _, let range):
            return .requestURL(urlParameters: ["date_range":range])
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .updateSugar, .updateInsulin,
             .updateTemperature, .updatePulse, .updateBloodOxygen,
             .writeList, .getCalibrate, .calibrate, .getLast:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        case .sugarList(let idOp), .insulinList(let idOp),
             .temperatureList(let idOp), .pulseList(let idOp), .bloodOxygenList(let idOp),
             .getStatictic(let idOp, _, _):
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            var headers = TypeHeaders.create(token: token)
            if let id = idOp {
                headers.updateValue("\(id)", forKey: "id")
            }
            return headers
        case .temperatureTest:
            return TypeHeaders.create(token: "6023014a1d4b44cc0217d5be3ed2b4f31c6a9450")
        }
    }
}
