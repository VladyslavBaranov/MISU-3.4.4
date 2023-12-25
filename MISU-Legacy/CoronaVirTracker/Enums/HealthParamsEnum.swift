//
//  HealthParamsEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum HealthParamsEnum: CaseIterable {
    case sugar
    case insuline
    case bloodOxygen
    case heartBeat
    case temperature
    case pressure
    
    static let headerParams = HeadersParamEnum.self
    
    var nameVorRequest: String {
        switch self {
        case .sugar:
            return "sugar"
        case .insuline:
            return "insulin"
        case .bloodOxygen:
            return "blood_oxygen"
        case .heartBeat:
            return "pulse"
        case .temperature:
            return "temperature"
        case .pressure:
            return "pressure"
        }
    }
    
    enum StaticticRange: Int, CaseIterable {
        case day = 1
        case week = 7
        case month = 30
        case year = 365
    }
    
    func headersParamEnum() -> HeadersParamEnum? {
        switch self {
        case .bloodOxygen:
            return .bloodOxygen
        case .heartBeat:
            return .heartBeat
        case .temperature:
            return .temperature
        case .pressure:
            return .pressure
        default:
            return nil
        }
    }
    
    static func getBy(string: String) -> HealthParamsEnum? {
        return allCases.first(where: {$0.nameVorRequest == string})
    }
}
