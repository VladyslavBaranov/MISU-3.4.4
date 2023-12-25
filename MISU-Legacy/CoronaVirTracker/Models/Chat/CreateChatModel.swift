//
//  CreateChatModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 02.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct CreateChat {
    let apiKey: String
    let receiverId: Int
    let isDoctor: Bool
    
    init (receiverId id: Int, isDoctor isDoc: Bool, apiKey apK: String = "8fba-pGAPjHt39K54x9j2A") {
        receiverId = id
        isDoctor = isDoc
        apiKey = apK
    }
}

extension CreateChat: Codable {
    private enum Keys: String, CodingKey {
        case apiKey = "api_key"
        case receiverId = "receiver_id"
        case isDoctor = "is_doctor"
    }
    
    func encodeToParameters() -> Parameters {
        return [Keys.apiKey.rawValue:apiKey,
                Keys.receiverId.rawValue:receiverId,
                Keys.isDoctor.rawValue:isDoctor]
    }
}
