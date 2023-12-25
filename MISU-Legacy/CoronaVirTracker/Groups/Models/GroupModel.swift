//
//  GroupModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 14.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct GroupModel {
    let id: Int
    var name: String?
    var admin: UserModel?
    var members: [UserModel] = []
    
    var isICreator: Bool { get { return admin?.id == UCardSingleManager.shared.user.id }}
    var allMembers: [UserModel] {
        get {
            var m = members
            if let a = admin { m.append(a) }
            return m
        }
    }
}

extension GroupModel {
    static func deleteUserParams(userId: Int) -> Parameters {
        return [Keys.member.rawValue:[userId]]
    }
}

extension GroupModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case name = "name"
        case admin = "creator"
        case members = "members"
        case member = "member"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        name = try? container.decode(String.self, forKey: .name)
        admin = try? container.decode(UserModel.self, forKey: .admin)
        members = (try? container.decode([UserModel].self, forKey: .members)) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        try? container.encode(admin, forKey: .admin)
        try? container.encode(members, forKey: .members)
    }
}
