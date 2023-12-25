//
//  ScaleFCEnum.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/19/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum ScaleFCEnum: Int {
    case celsius = 0
    case fahrenheit = 1
    
    var key: String {
        return String(describing: self)
    }
    
    static func get(_ id: Int) -> ScaleFCEnum {
        switch id {
        case 0:
            return ScaleFCEnum.celsius
        case 1:
            return ScaleFCEnum.fahrenheit
        default:
            return ScaleFCEnum.celsius
        }
    }
    
    var localized: String {
        switch self {
        default: return NSLocalizedString(self.key, comment: "")
        }
    }
}
