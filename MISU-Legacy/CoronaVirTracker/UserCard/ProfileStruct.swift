//
//  ProfileStruct.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/17/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum ProfileStruct: Int, CaseIterable {
    case generalInfo = 0
    case symptoms = 1
    case whatIDo = 2
    case whatINeed = 3
    case additionalInfo = 4
    case help = 5
    
    var key: String {
        return String(describing: self)
    }
}

enum AdditionalInfoStruct: Int, CaseIterable {
    case email = 0
    case scaleFC = 1
    
    var key: String {
        return String(describing: self)
    }
}

enum CellIds: String {
    case general = "GeneralInfoCell"
    case symptoms = "SymptomsCell"
    case whatIDo = "WhatIDoCell"
    case additionalInfo = "AdditionalInfoCell"
    case help = "HelpCell"
    case headerSymp = "headerSymp"
    case headerAddi = "headerAddi"
    case header = "Header"
    case footer = "Footer"
}

