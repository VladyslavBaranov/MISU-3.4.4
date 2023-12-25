//
//  VerifyingModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.04.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct VerifyingModel {
    var verified: Bool = false
    var approved: Bool = false
}

extension VerifyingModel: Codable {
    private enum Keys: String, CodingKey {
        case verified = "verified"
        case approved = "approved"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        verified = try container.decode(Bool.self, forKey: .verified)
        approved = try container.decode(Bool.self, forKey: .approved)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(verified, forKey: .verified)
        try container.encode(approved, forKey: .approved)
    }
}
