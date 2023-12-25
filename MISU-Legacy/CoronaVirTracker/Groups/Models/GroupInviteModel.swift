//
//  GroupInviteModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum GroupInviteStatus {
    case accepted
    case declined
    case pending
    
    var localized: String {
        get {
            switch self {
            case .accepted:
                return NSLocalizedString("Accepted", comment: "")
            case .declined:
                return NSLocalizedString("Declined", comment: "")
            case .pending:
                return NSLocalizedString("Pending...", comment: "")
            }
        }
    }
}

struct GroupInviteModel {
    let id: Int
    var sender: UserModel?
    var recipient: UserModel?
    var status: Bool?
    var groupId: Int?
    var statusEnum: GroupInviteStatus {
        switch status {
        case true:
            return .accepted
        case false:
            return .declined
        default:
            return .pending
        }
    }
    
    mutating func accept() {
        status = true
    }
    
    mutating func decline() {
        status = false
    }
    
    func encodeStatus() -> Parameters {
        return [Keys.status.rawValue:status as Any]
    }
}

extension GroupInviteModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case sender = "sender"
        case recipient = "recipient"
        case status = "status"
        case groupId = "group"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        sender = try? container.decode(UserModel.self, forKey: .sender)
        recipient = try? container.decode(UserModel.self, forKey: .recipient)
        status = try? container.decode(Bool.self, forKey: .status)
        groupId = try? container.decode(Int.self, forKey: .groupId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(sender, forKey: .sender)
        try? container.encode(recipient, forKey: .recipient)
        try? container.encode(status, forKey: .status)
        try? container.encode(groupId, forKey: .groupId)
    }
}
