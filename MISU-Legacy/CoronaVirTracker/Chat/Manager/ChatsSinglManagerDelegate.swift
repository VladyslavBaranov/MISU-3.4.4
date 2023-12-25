//
//  ChatsSinglManagerDelegate.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

protocol ChatsSinglManagerDelegate {
    func chatsListUpdated()
}

protocol AppIconNewMessagesDelegate {
    func gotNewMessage(_ count: Int)
}

protocol TabBarNewMessagesDelegate {
    func gotNewMessage(_ count: Int)
}

protocol ChatsIconNewMessagesDelegate {
    func gotNewMessage(_ count: Int)
}

protocol ChatMessagesDelegate {
    func messagesUpdated(_ chat: ChatModel)
}
