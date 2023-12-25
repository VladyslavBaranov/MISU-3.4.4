//
//  ChatsThreadsModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 02.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

class ChatsThreadsPM: PaginatedModel<[ChatModelForAllReq]> {
    var threads: [ChatModelForAllReq] = []
    
    override init() {
        super.init()
    }

    private enum Keys: String, CodingKey {
        case threads = "threads"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: Keys.self)
        
        threads = (try? container.decode([ChatModelForAllReq].self, forKey: .threads)) ?? []
    }
}

struct ChatsThreadsModel {
    var threads: [ChatModel] = []
}

extension ChatsThreadsModel: Codable {
    private enum Keys: String, CodingKey {
        case threads = "threads"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        if let thrds = try? container.decode([ChatModelForAllReq].self, forKey: .threads) {
            thrds.forEach { thrd in
                threads.append(ChatModel(id: thrd.id, participants: thrd.participants, messages: thrd.messages, lastMessageData: thrd.lastMessageData))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(threads, forKey: .threads)
    }
}

struct ChatThreadsModel {
    let threadMessages: [ChatModel]
}

extension ChatThreadsModel: Codable {
    private enum Keys: String, CodingKey {
        case threadMessages = "thread_messages"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        threadMessages = (try? container.decode([ChatModel].self, forKey: .threadMessages)) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(threadMessages, forKey: .threadMessages)
    }
}
