//
//  SymptomModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 20.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct SymptomModel {
    let id: Int
    let name: String?
    var imageLink: String? = nil
    
    init (id id_: Int, name nm: String? = nil) {
        self.id = id_
        self.name = nm
    }
}

extension SymptomModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case name = "name"
        case imageLink = "image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        name = try? container.decode(String.self, forKey: .name)
        imageLink = try? container.decode(String.self, forKey: .imageLink)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
    }
}
