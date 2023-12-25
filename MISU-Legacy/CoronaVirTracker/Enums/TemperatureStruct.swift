//
//  TemperatureStruct.swift
//  CoronaVirTracker
//
//  Created by WH ak on 09.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct TemperatureStruct {
    static var intRange: ClosedRange<Int> {
        get {
            return 34...41
        }
    }
    
    static var minIntValue: Int {
        get {
            guard let min = self.intRange.first else { return 0 }
            return min
        }
    }
    
    static var decRange: ClosedRange<Int> {
        get {
            return 0...9
        }
    }
    
    enum type: Int, CaseIterable {
        case integer = 0
        case dec = 1
    }
}
