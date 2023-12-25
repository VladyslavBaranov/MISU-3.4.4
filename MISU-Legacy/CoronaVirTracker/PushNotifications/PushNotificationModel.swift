//
//  PushNotificationModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

/*
 
[
AnyHashable("sender"): 36,
AnyHashable("text"): 123,
AnyHashable("id"): 290,
AnyHashable("aps"): {
    alert =     {
        body = 123;
        title = "\U0421\U043e\U0444\U0456\U044f \U0421\U043e\U0444\U0443\U0448\U043a\U0430";
    };
    sound = default;
},
AnyHashable("chat_id"): 20
]
 
*/

struct PushNotificationModel {
    let chatId: Int?
    let senderId: Int?
    let messageId: Int?
    let messageText: String?
    
    init () {
        chatId = nil
        senderId = nil
        messageId = nil
        messageText = nil
    }
}

extension PushNotificationModel: Codable {
    private enum Keys: String, CodingKey {
        case chatId = "chat_id"
        case senderId = "sender"
        case messageId = "id"
        case messageText = "text"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        chatId = try? container.decode(Int.self, forKey: .chatId)
        senderId = try? container.decode(Int.self, forKey: .senderId)
        messageId = try? container.decode(Int.self, forKey: .messageId)
        messageText = try? container.decode(String.self, forKey: .messageText)
    }
    
    init(decode: [AnyHashable: Any]) {
        //let dict: [String:Any]? = decode as? [String:Any]
        chatId = decode[Keys.chatId.rawValue] as? Int
        senderId = decode[Keys.senderId.rawValue] as? Int
        messageId = decode[Keys.messageId.rawValue] as? Int
        messageText = decode[Keys.messageText.rawValue] as? String
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(chatId, forKey: .chatId)
        try? container.encode(senderId, forKey: .senderId)
        try? container.encode(messageId, forKey: .messageId)
        try? container.encode(messageText, forKey: .messageText)
    }
}
