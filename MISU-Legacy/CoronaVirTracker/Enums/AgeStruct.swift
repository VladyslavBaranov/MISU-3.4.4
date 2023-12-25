//
//  AgeStruct.swift
//  CoronaVirTracker
//
//  Created by WH ak on 09.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct AgeStruct {
    static var range: ClosedRange<Int> {
        get {
            return 0...120
        }
    }
    
    static var maxValue: Int {
        get {
            guard let max = self.range.last else { return 0 }
            return max
        }
    }
    
    static var minValue: Int {
        get {
            guard let min = self.range.first else { return 0 }
            return min
        }
    }
}
