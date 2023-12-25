//
//  ImageCacheModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.09.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

struct ImageCacheModel {
    let key: String
    let value: Data
    let expirationDate: Date

    init(key _key: String, value _value: Data, expirationDate _date: Date = Date()) {
        key = _key
        value = _value
        expirationDate = _date
    }
}

extension ImageCacheModel: Codable {
    private enum Keys: String, CodingKey {
        case key = "key"
        case value = "value"
        case expirationDate = "expirationDate"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        key = try container.decode(String.self, forKey: .key)
        value = try container.decode(Data.self, forKey: .value)
        expirationDate = try container.decode(Date.self, forKey: .expirationDate)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(key, forKey: .key)
        try container.encode(value, forKey: .value)
        try container.encode(expirationDate, forKey: .expirationDate)
    }
}
