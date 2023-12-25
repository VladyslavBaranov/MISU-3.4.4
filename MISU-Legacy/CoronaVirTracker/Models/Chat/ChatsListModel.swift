//
//  MessageListModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class Chat: Codable {
    var id: Int?
    var participants: [UserModel] = []
    var last_message: String?
    var messages: [Message] = []
    var unread: Int = 0
    var messagesIds: [Message] = []
    var allMessages: [Int:Message] = [:]
    
    var messagesInProgress: [Message] = []
    var messagesIdsAndInProg: [Message] {
        return messagesInProgress + messagesIds
    }
    
    var other: UserModel? {
        return participants.first(where: {$0.id != UCardSingleManager.shared.user.id})
    }
    
    init() {}
    
    init(id id_: Int) {
        id = id_
    }
    
    init(id: Int, participants parts: [UserModel], messages mess: [Message], lastMessageData last: String?) {
        self.id = id
        self.participants = parts
        self.messages = mess
        self.last_message = last
    }
    
    enum Keys: String, CodingKey {
        case id = "id"
        case participants = "participants"
        case last_message = "last_message"
        case messages = "messages"
        case unread = "unread"
        case messagesIds = "messagesIds"
        case allMessages = "allMessages"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try? container.decode(Int.self, forKey: .id)
        participants = (try? container.decode([UserModel].self, forKey: .participants)) ?? []
        last_message = try? container.decode(String.self, forKey: .last_message)
        messages = (try? container.decode([Message].self, forKey: .messages)) ?? []
        unread = (try? container.decode(Int.self, forKey: .unread)) ?? 0
        messagesIds = (try? container.decode([Message].self, forKey: .messagesIds)) ?? []
        allMessages = (try? container.decode([Int:Message].self, forKey: .allMessages)) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(id, forKey: .id)
        try? container.encode(participants, forKey: .participants)
        try? container.encode(last_message, forKey: .last_message)
        try? container.encode(messages, forKey: .messages)
        try? container.encode(unread, forKey: .unread)
        try? container.encode(messagesIds, forKey: .messagesIds)
        try? container.encode(allMessages, forKey: .allMessages)
    }
}

extension Chat: ChatDataUtils {
    func sendMessage(_ message: Message) {
        let id = (messagesInProgress.first?.id ?? -1) - 1
        messagesInProgress.insert(.init(id: id), at: 0)
        message.id = id
        allMessages.updateValue(message, forKey: id)
    }
    
    func removeTemp(_ message: Message) {
        messagesInProgress.removeAll(where: {$0.id == message.id})
        allMessages.removeValue(forKey: message.id ?? -1)
    }
    
    func updateSelfRequest(_ completion: (()->Void)?) {
        guard let cId = id else {
            completion?()
            return
        }
        _ = ChatManager.shared.getChatBy(id: cId) { list_, error_ in
            //print("### updateSelfRequest \(String(describing: list_))")
            //print("### updateSelfRequest error \(String(describing: error_))")
            
            if let ch = list_?.first(where: {$0.id == cId}) {
                self.update(ch)
            }
            
            completion?()
        }
    }
    
    func update(_ ch: Chat) {
        last_message = ch.last_message
        messages = ch.messages
        unread = ch.unread
        
        participants.enumerated().forEach { index, user in
            if ch.participants.first(where: {$0.id == user.id}) == nil {
                participants.removeAll(where: {$0.id == user.id})
            }
        }
        
        ch.participants.forEach { user in
            if participants.first(where: {$0.id == user.id}) == nil {
                participants.append(user)
            }
        }
        updateAllChatsInCache()
    }
    
    func updateParticipants(_ completion: (()->Void)?) -> URLSessionTask? {
        //print("### updateParticipants participants: \(String(describing: participants.count))")
        //print("### updateParticipants otherId: \(String(describing: other?.id))")
        guard let oId = other?.id else {
            completion?()
            return nil
        }
        return UsersListManager.shared.getAllUsersReturn(id: oId, one: true) { (list, error) in
            //print("### updateParticipants \(String(describing: list?.count))")
            //print("### updateParticipants error \(String(describing: error))")
            if var newUser = list?.first {
                //print("### updateParticipants newUser \(String(describing: newUser.id))")
                //newUser.username = other.username
                let num = self.participants.first(where: {$0.id == newUser.id})?.username
                newUser.username = newUser.username ?? num
                newUser.number = newUser.number ?? num
                
                self.participants.removeAll(where: {$0.id == newUser.id})
                self.participants.append(newUser)
                self.updateAllChatsInCache()
            }
            
            completion?()
        }
    }
    
    func updateMessegasIdsList(_ completion: ((_ isChanges: Bool)->Void)?) {
        guard let cId = id else { return }
        ChatManager.shared.getMessageIdsListOf(chatId: cId) { listIds, error in
            //print("### updateMessegasIdsList \(String(describing: listIds?.count))")
            //print("### updateMessegasIdsList error \(String(describing: error))")
            
            var changes = false
            
            if let ci: [Message] = listIds?.reversed() {
                changes = ci != self.messagesIds
                self.messagesIds = ci
                self.updateAllChatsInCache()
            }
            
            changes ? completion?(true) : completion?(false)
            
        }
    }
}

struct ChatModel {
    let id: Int
    var participants: [UserModel] = []
    var messages: [MessageModel] = []
    var lastMessageData: String?
    var unreadedMessages: Int = 0
    
    init(id: Int) {
        self.id = id
    }
    
    init(id: Int, participants parts: [UserModel], messages mess: [MessageModel], lastMessageData last: String?) {
        self.id = id
        self.participants = parts
        self.messages = mess
        self.lastMessageData = last
    }
}

extension ChatModel {
    mutating func updateNewData(_ newChat: ChatModel, removeOther: Bool) {
        lastMessageData = newChat.lastMessageData ?? self.lastMessageData
        updateMessages(newChat.messages, removeOther: removeOther)
        updateParticipants(newChat.participants)
    }
    
    private mutating func updateMessages(_ newMessages: [MessageModel], removeOther: Bool) {
        // check if message was disapear
        if removeOther {
            messages.forEach { msg in
                //print("### r \(msg.recommendation)")
                if newMessages.first(where: {$0.id == msg.id}) == nil, let removeIndex = messages.firstIndex(where: {$0.id == msg.id}) {
                    messages.remove(at: removeIndex)
                }
            }
        }
        
        // check if got new message
        newMessages.forEach { newMsg in
            if messages.first(where: { $0.id == newMsg.id }) == nil {
                messages.append(newMsg)
                if !(newMsg.isMyMessage ?? false) {
                    unreadedMessages += 1
                }
            }
            
            if (newMsg.recommendation || newMsg.isInvitation), let index = messages.firstIndex(where: { $0.id == newMsg.id }) {
                 messages[index] = newMsg
            }
        }
        
        messages.sort { (first, second) -> Bool in
            guard let fDate = first.dateTimeString?.toDate() else { return false }
            guard let sDate = second.dateTimeString?.toDate() else { return true }
            if fDate.compare(sDate) == .orderedDescending {
                return true
            }
            return false
        }
        
        // print("End updateMessages id: \(self.id) count: \(self.messages.count)")
    }
    
    private mutating func updateParticipants(_ newParticipants: [UserModel]) {
        // check if user was disapear
        participants.forEach { user in
            if newParticipants.first(where: {$0.id == user.id}) == nil, let removeIndex = participants.firstIndex(where: {$0.id == user.id}) {
                participants.remove(at: removeIndex)
            }
        }
        
        // check if new user was added
        newParticipants.forEach { newUser in
            if participants.first(where: { $0.id == newUser.id }) == nil{
                participants.append(newUser)
            }
        }
    }
    
    mutating func sendMessage(_ message: MessageModel, collectionView: UICollectionView) {
        self.messages.insert(message, at: 0) // .append(message)
        // send request
    }
    
    func getOther() -> UserModel? {
        return participants.first(where: {$0.id != UCardSingleManager.shared.user.id})
    }
    
    mutating func updateOther(_ user: UserModel) {
        guard let index = participants.firstIndex(where: {$0.id == getOther()?.id}) else { return }
        participants[index] = user
    }
}

extension ChatModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "thread_id"
        case participants = "partner"
        case messages = "thread_messages"
        case lastMessageData = "datetime"
        case unreadedMessages = "unreadedMessages"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        if let participant = try? container.decode(UserModel.self, forKey: .participants) {
            participants = [participant]
        } else {
            participants = (try? container.decode([UserModel].self, forKey: .participants)) ?? []
        }
        messages = (try? container.decode([MessageModel].self, forKey: .messages)) ?? []
        lastMessageData = try? container.decode(String.self, forKey: .lastMessageData)
        unreadedMessages = (try? container.decode(Int.self, forKey: .unreadedMessages)) ?? 0
        
        //print("unreadedMessages got: \(id) \(unreadedMessages)")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(participants, forKey: .participants)
        try? container.encode(messages, forKey: .messages)
        try? container.encode(lastMessageData, forKey: .lastMessageData)
        try? container.encode(unreadedMessages, forKey: .unreadedMessages)
        //print("unreadedMessages archive: \(id) \(unreadedMessages)")
    }
}


/*
{"threads":[{"id":30,"participants":[{"id":27,"username":"doctor22@gmail.com"}],"last_message":null,"messages":[]},{"id":20,"participants":[{"id":37,"username":"+380674962499"}],"last_message":"2020-07-29T11:35:06.789956Z","messages":[{"id":374,"text":"123qweqweqweqweqwe","sender":36,"datetime":"2020-07-29T11:35:06.789956Z"}]},{"id":26,"participants":[{"id":50,"username":"+380963892972"}],"last_message":"2020-07-26T17:19:05.856102Z","messages":[{"id":298,"text":"Asd","sender":50,"datetime":"2020-07-26T17:19:05.856102Z"}]}]}

 {"thread_id":30,"thread_messages":[],"messages_total":0,"messages_sent":0,"messages_received":0,"partner":{"id":27,"username":"doctor22@gmail.com"}}
 
 */


struct ChatModelForAllReq {
    let id: Int
    var participants: [UserModel] = []
    var messages: [MessageModel] = []
    var lastMessageData: String?
    var unreadedMessages: Int = 0
    
    init(id: Int) {
        self.id = id
    }
    
    func getChatModel() -> ChatModel {
        return ChatModel(id: id, participants: participants, messages: messages, lastMessageData: lastMessageData)
    }
}

extension ChatModelForAllReq: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case participants = "participants"
        case messages = "messages"
        case lastMessageData = "last_message"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        participants = (try? container.decode([UserModel].self, forKey: .participants)) ?? []
        messages = (try? container.decode([MessageModel].self, forKey: .messages)) ?? []
        lastMessageData = try? container.decode(String.self, forKey: .lastMessageData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(participants, forKey: .participants)
        try? container.encode(messages, forKey: .messages)
        try? container.encode(lastMessageData, forKey: .lastMessageData)
    }
}
