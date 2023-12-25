//
//  ConstantsModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct ConstantsModel {
    let id: Int?
    let idStr: String?
    let value: String?
    let color: String?
    
    init() {
        id = nil
        idStr = nil
        value = nil
        color = nil
    }
    
    init(id: Int, idStr: String? = nil, value: String? = nil, color: String? = nil) {
        self.id = id
        self.idStr = idStr
        self.value = value
        self.color = color
    }
}

extension ConstantsModel: Decodable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case value = "value"
        case color = "color"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        idStr = try? container.decode(String.self, forKey: .id)
        value = try? container.decode(String.self, forKey: .value)
        color = try? container.decode(String.self, forKey: .color)
    }
}
