//
//  IndicatorCalibrationModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 23.05.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

// {"id":1,"exact_value":120.0,"value":116.0,"coefficient":1.034,"type":"pressure"}

class IndicatorCalibrationModel: Decodable, ParamsEncodeble {
    var exact: HealthParameterModel?
    var bracelet: HealthParameterModel?
    var strType: String?
    var type: HealthParamsEnum?
    
    enum Keys: String, CodingKey {
        case exact = "exact"
        case bracelet = "bracelet"
        case type = "type"
    }
    
    init() { }
    
    init(tonom tm: HealthParameterModel, bracelet br: HealthParameterModel, type tp: String = "pressure") {
        exact = tm
        bracelet = br
        strType = tp
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        exact = try? container.decode(HealthParameterModel.self, forKey: .exact)
        bracelet = try? container.decode(HealthParameterModel.self, forKey: .bracelet)
        if let str = try? container.decode(String.self, forKey: .type) {
            strType = str
            type = HealthParamsEnum.getBy(string: str)
        }
    }
    
    func encode() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(exact?.encode(), forKey: .exact)
        try? container.updateValue(bracelet?.encode(), forKey: .bracelet)
        try? container.updateValue(strType, forKey: .type)
        
        return container.dictionary
    }
}
