//
//  SendMessage.swift
//  CoronaVirTracker
//
//  Created by WH ak on 02.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

struct UnreadedChats: Decodable {
    let count: Int
    
    enum Keys: String, CodingKey {
        case count = "count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        count = try container.decode(Int.self, forKey: .count)
    }
}

struct SendMessage {
    let apiKey: String
    let senderId: Int
    let message: String
    let recommendation: Bool
    let image: UIImage?
    
    init (sender id: Int, message m: String, recom: Bool = false, img: UIImage? = nil, apiKey apK: String = "8fba-pGAPjHt39K54x9j2A") {
        senderId = id
        message = m
        apiKey = apK
        recommendation = recom
        image = img
    }
    
    func getMessageModel() -> Message {
        return Message(message, my: true, recom: recommendation)
    }
}

extension SendMessage {
    private enum Keys: String, CodingKey {
        case apiKey = "api_key"
        case senderId = "sender_id"
        case message = "message"
        case recommendation = "recommendation"
        case image = "image"
    }
    
    func encodeToParameters() -> (params: Parameters, files: Files) {
        var dict: Parameters = [Keys.apiKey.rawValue:apiKey,
                                Keys.senderId.rawValue:senderId,
                                Keys.message.rawValue:message]
        if recommendation {
            dict.updateValue(recommendation, forKey: Keys.recommendation.rawValue)
        }
        
        var files: Files = []
        if let img = image {
            files.append(FileModel(name: "image_\(Date().getTimeDateForRequest())", type: .imageJpg, data: img.jpegData(compressionQuality: 1)))
        }
        
        return (dict, files)
    }
}
