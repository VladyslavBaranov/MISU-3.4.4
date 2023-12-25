//
//  NeedsModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/17/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct NeedsModel {
    var name: String
    var count: Int?
    var done: Bool?
    
    init(name: String) {
        self.name = name
    }
    
    init(name: String, count: Int, done: Bool) {
        self.name = name
        self.count = count
        self.done = done
    }
}

extension NeedsModel: Equatable {
    static func ==(first: NeedsModel, second: NeedsModel) -> Bool {
        return first.name == second.name && first.count == second.count
    }
    static func !=(first: NeedsModel, second: NeedsModel) -> Bool {
        return first.name != second.name || first.count != second.count
    }
}

extension NeedsModel: Codable {
    private enum Keys: String, CodingKey {
        case name = "name"
        case count = "count"
        case done = "done"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        count = try? container.decode(Int.self, forKey: .count)
        done = try? container.decode(Bool.self, forKey: .done)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(name, forKey: .name)
        try? container.encode(count, forKey: .count)
        try? container.encode(done, forKey: .done)
    }
}
