//
//  SugarInsulineEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum SugarInsulineEnum: String, CaseIterable {
    case sugar = "Sugar"
    case insuline = "Insulin"
    
    var index: Int {
        get {
            switch self {
            case .sugar:
                return 0
            case .insuline:
                return 1
            }
        }
    }
    
    var localized: String {
        get { return NSLocalizedString(self.rawValue, comment: "")}
    }
    
    var healtParamEnum: HealthParamsEnum {
        switch self {
        case .sugar:
            return .sugar
        case .insuline:
            return .insuline
        }
    }
}
