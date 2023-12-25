//
//  HealthStatisticModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/11/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct HealthStatisticModel {
    var well: Int
    var weak: Int
    var ill: Int
    var dead: Int
    
    init(well: Int, weak: Int, ill: Int, dead: Int) {
        self.well = well
        self.weak = weak
        self.ill = ill
        self.dead = dead
    }
}

extension HealthStatisticModel: Codable {
    private enum Keys: String, CodingKey {
        case well = "green"
        case weak = "yellow"
        case ill = "red"
        case dead = "black"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        well = (try? container.decode(Int.self, forKey: .well)) ?? 0
        weak = (try? container.decode(Int.self, forKey: .weak)) ?? 0
        ill = (try? container.decode(Int.self, forKey: .ill)) ?? 0
        dead = (try? container.decode(Int.self, forKey: .dead)) ?? 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(well, forKey: .well)
        try container.encode(weak, forKey: .weak)
        try container.encode(ill, forKey: .ill)
        try container.encode(dead, forKey: .dead)
    }
    
    func diferentParams(with old: HealthStatisticModel) -> Parameters {
        var params: Parameters = [:]
        
        if well != old.well { params.updateValue(well, forKey: Keys.well.rawValue) }
        if weak != old.weak { params.updateValue(weak, forKey: Keys.weak.rawValue) }
        if ill != old.ill { params.updateValue(ill, forKey: Keys.ill.rawValue) }
        
        return params
    }
}



extension HealthStatisticModel: Equatable {
    static func !=(first: HealthStatisticModel, second: HealthStatisticModel) -> Bool {
        return first.well != second.well || first.weak != second.weak || first.ill != second.ill 
    }
}
