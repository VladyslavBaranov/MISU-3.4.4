//
//  ConstantsEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum ConstantsEnum: EnumKit {
    case point
    case sex
    case language
    case confirmed
    case state
    case vaccine
    
    var pathNameKey: String { get { return "name" } }
    var pathNameParam: Parameters { get { return [self.pathNameKey:self.key] } }
}
