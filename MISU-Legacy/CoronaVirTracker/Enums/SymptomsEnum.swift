//
//  SymptomsEnum.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/17/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum Symptoms: String, CaseIterable {
    case headache = "Headache"
    case earache = "Earache"
    case cold = "Cold"
    case highBloodPressure = "High blood pressure"
    case lowBloodPressure = "Low blood pressure"
    case fever = "Fever"
    case highTemperature = "High temperature"
    case lowTemperature = "Low temperature"
    case weakness = "Weakness"
    case feelBad = "Feel bad"
    case feelDizzy = "Feel dizzy"
    case coughing = "Coughing"
    case sneezing = "Sneezing"
    case stuffyNose = "Stuffy nose"
    case soreThroat = "Sore throat"
    
    var localized: String {
        switch self {
        default: return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    func get(id: Int) -> Symptoms? {
        switch id {
        case 0:
            return .headache
        default:
            return nil
        }
    }
}
