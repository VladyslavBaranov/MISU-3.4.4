//
//  IllnessListItemModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct IllnessListItemModel {
    let id: Int
    var name: String?
    var indication: String?
    var additional: String?
}

extension IllnessListItemModel: Decodable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case name = "name"
        case indication = "indication"
        case additional = "additional"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        name = try? container.decode(String.self, forKey: .name)
        indication = try? container.decode(String.self, forKey: .indication)
        additional = try? container.decode(String.self, forKey: .additional)
    }
}
