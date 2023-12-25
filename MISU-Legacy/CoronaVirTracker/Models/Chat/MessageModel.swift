//
//  MessageModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

/*  {"id":794,
    "text":"Користувач запрошує вас до своєї сімейної групи.",
    "sender":16,
    "datetime":"2020-12-21T17:28:54.689094Z",
    "recommendation":false,"image":null,
    "request":{"id":4,"group":20,"status":null}}, */

//{"id":690,"text":"Привіт","sender":4,"datetime":"2020-12-07T13:34:25.887983Z","recommendation":false,"image":null,"request":null,"ordered":false}

@objc class Message: NSObject, Codable {
    var id: Int?
    var text: String?
    var sender: Int?
    var dateTimeString: String?
    var recommendation: Bool = false
    var imageLink: String?
    var invitation: GroupInviteModel?
    var isOrdered: Bool = false
    var cacheUpdated: Bool = false
    
    var sendDate: Date? {
        return dateTimeString?.toDate()
    }
    
    var sendDateString: String? {
        return sendDate?.getTimeDateWitoutToday()
    }
    
    var isMyMessage: Bool {
        return UCardSingleManager.shared.user.id == sender
    }
    
    init(_ txt: String, my: Bool, recom: Bool = false, date: Date = Date()) {
        self.id = -1001
        self.sender = my ? UCardSingleManager.shared.user.id : -1002
        self.text = txt
        self.text?.clearEmptyEntersAndSpaces()
        self.dateTimeString = date.getTimeDateForRequest()
        self.recommendation = recom
    }
    
    init(id id_: Int) {
        self.id = id_
    }
    
    enum Keys: String, CodingKey {
        case id = "id"
        case text = "text"
        case sender = "sender"
        case dateTimeString = "datetime"
        case recommendation = "recommendation"
        case imageLink = "image"
        case invitation = "request"
        case isOrdered = "ordered"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try? container.decode(Int.self, forKey: .id)
        text = try? container.decode(String.self, forKey: .text)
        sender = try? container.decode(Int.self, forKey: .sender)
        dateTimeString = try? container.decode(String.self, forKey: .dateTimeString)
        recommendation = (try? container.decode(Bool.self, forKey: .recommendation)) ?? false
        imageLink = try? container.decode(String.self, forKey: .imageLink)
        invitation = try? container.decode(GroupInviteModel.self, forKey: .invitation)
        isOrdered = (try? container.decode(Bool.self, forKey: .isOrdered)) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(id, forKey: .id)
        try? container.encode(text, forKey: .text)
        try? container.encode(sender, forKey: .sender)
        try? container.encode(dateTimeString, forKey: .dateTimeString)
        try? container.encode(recommendation, forKey: .recommendation)
        try? container.encode(imageLink, forKey: .imageLink)
        try? container.encode(invitation, forKey: .invitation)
        try? container.encode(isOrdered, forKey: .isOrdered)
    }
}

extension Message: ChatDataUtils {
    func getInfo(_ completion: (()->Void)?) -> URLSessionTask? {
        guard let mId = id, mId >= 0 else { return nil }
        return ChatManager.shared.getMessageBy(id: mId) { mList, error in
            //print("### getMessageBy \(String(describing: mList?.count))")
            //print("### getMessageBy error \(String(describing: error))")
            
            if let msg = mList?.first {
                self.text = msg.text
                self.sender = msg.sender
                self.dateTimeString = msg.dateTimeString
                self.recommendation = msg.recommendation
                self.imageLink = msg.imageLink
                self.invitation = msg.invitation
                self.isOrdered = msg.isOrdered
                
                self.cacheUpdated = true
                
                self.updateAllChatsInCache()
            }
            
            completion?()
        }
        
    }
}

struct MessageModel {
    let id: Int
    var text: String?
    var sender: Int?
    var dateTimeString: String?
    var time: String?
    var sendDate: Date? {
        didSet {
            time = self.getTimeString()
        }
    }
    var status: MessageStatusEnum?
    var isMyMessage: Bool?
    var recommendation: Bool = false
    var imageLink: String?
    var imageUI: UIImage?
    
    var invitation: GroupInviteModel?
    var isInvitation: Bool {
        get { return invitation != nil }
    }
    var isOrdered: Bool?
    
    init(id: Int) {
        self.id = id
        self.sendDate = Date()
    }
    
    init(_ txt: String, my: Bool, recom: Bool = false, date: Date = Date()) {
        self.id = -1001
        self.isMyMessage = my
        self.text = txt
        self.text?.clearEmptyEntersAndSpaces()
        self.status = .notSended
        self.sendDate = date
        self.recommendation = recom
    }
}

extension MessageModel {
    func getTimeString() -> String? {
        let calendar = Calendar.current
        guard let dt = sendDate else { return nil }
        let hour = calendar.component(.hour, from: dt)
        let minutes = calendar.component(.minute, from: dt)
        if minutes < 10 {
            return "\(hour):0\(minutes)"
        }
        return "\(hour):\(minutes)"
    }
}

extension MessageModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case text = "text"
        case dateTimeString = "datetime"
        case time = "time"
        case date = "date"
        case status = "status"
        case isMyMessage = "isMyMessage"
        case sender = "sender"
        case recommendation = "recommendation"
        case imageLink = "image"
        case imageUI = "ui_image"
        case invitation = "request"
        case isOrdered = "ordered"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        text = try? container.decode(String.self, forKey: .text)
        self.text?.clearEmptyEntersAndSpaces()
        dateTimeString = try? container.decode(String.self, forKey: .dateTimeString)
        time = try? container.decode(String.self, forKey: .time)
        sendDate = (try? container.decode(Date.self, forKey: .date)) ?? Date()

        if let stts = try? container.decode(Int.self, forKey: .status) {
            status = MessageStatusEnum.getBy(stts)
        }
        
        isMyMessage = try? container.decode(Bool.self, forKey: .isMyMessage)
        sender = try? container.decode(Int.self, forKey: .sender)
        
        isMyMessage = UCardSingleManager.shared.user.id == sender
        recommendation = (try? container.decode(Bool.self, forKey: .recommendation)) ?? false
        imageLink = try? container.decode(String.self, forKey: .imageLink)
        invitation = try? container.decode(GroupInviteModel.self, forKey: .invitation)
        
        isOrdered = try? container.decode(Bool.self, forKey: .isOrdered)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(text, forKey: .text)
        try? container.encode(dateTimeString, forKey: .dateTimeString)
        try? container.encode(time, forKey: .time)
        try container.encode(sendDate, forKey: .date)
        if let stts = status?.rawValue {
            try? container.encode(stts, forKey: .status)
        }
        try? container.encode(isMyMessage, forKey: .isMyMessage)
        try? container.encode(sender, forKey: .sender)
        try? container.encode(recommendation, forKey: .recommendation)
        try? container.encode(imageLink, forKey: .imageLink)
        try? container.encode(invitation, forKey: .invitation)
        try? container.encode(isOrdered, forKey: .isOrdered)
        //try? container.encode(imageUI, forKey: .imageUI)
    }
}
