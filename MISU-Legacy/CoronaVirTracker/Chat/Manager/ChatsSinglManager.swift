//
//  ChatsSinglManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Parameters
class ChatsSinglManager {
    var delegate: ChatsSinglManagerDelegate?
    var appIconDelegate: AppIconNewMessagesDelegate?
    var tabBarDelegate: TabBarNewMessagesDelegate?
    var chatsIconDelegate: ChatsIconNewMessagesDelegate?
    var chatMessagesDelegate: ChatMessagesDelegate?
    
    var updateAllChatsTimer: Timer?
    var readyupdateAllChats: Bool = true
    var unreadedChatsTimer: Timer?
    
    let drugsChatOtherID: Int = 22
    let drugsChatDocID: Int = 10
    
    var chatsDict: [Int:Chat] = ChatCM.shared.cachedChat {
        didSet {
            ChatCM.shared.cachedChat = chatsDict
        }
    }
    
    static let shared = ChatsSinglManager()
    private init() {
        updateUnreadedChatsCount()
        startRegularyUpdate()
    }
}



extension ChatsSinglManager {
    func setChat(_ ch: Chat) {
        guard let cId = ch.id else { return }
        chatsDict.updateValue(ch, forKey: cId)
    }
    
    func getChatBy(id: Int) -> Chat? {
        return chatsDict[id]
    }
}



// MARK: - Messages control
extension ChatsSinglManager {
    func gotPushNotification(_ notification: PushNotificationModel) {
        //print("### N G \(notification)")
        ChatsSinglManager.shared.updateUnreadedChatsCount()
    }
    
    func openPushNotification(_ notification: PushNotificationModel, navController: UINavigationController? = nil) {
        print("### Open chat: \(String(describing: notification.chatId))")
        let topVC = UIApplication.topViewController()
        guard let chatId = notification.chatId else { return }
        if let chatVC = topVC as? ChatVC {
            if chatId == chatVC.chat.id { return }
        }
        let ch = ChatsSinglManager.shared.getChatBy(id: notification.chatId ?? -123)
        if ch == nil {
            ChatsSinglManager.shared.setChat(Chat(id: chatId))
        }
        let vc = ChatVC(chat: ch ?? Chat(id: chatId))
        vc.hidesBottomBarWhenPushed = true
        if let tv = topVC {
            tv.navigationController?.pushViewController(vc, animated: true)
        } else {
            navController?.pushViewController(vc, animated: true)
        }
    }
    
    func openedChat(_ chat: ChatModel) {
        /*guard let index = chatsList.firstIndex(where: {$0.id == chat.id}) else { return }
        chatsList[index].unreadedMessages = 0
        print(chatsList[index].unreadedMessages)*/
        ///safeChatsListUpdated(haveToSaveToCache: true)
    }
}



// MARK: - Server connections
extension ChatsSinglManager {
    func createChatWith(_ userToSend: UserModel, completion: ((Chat?)->Void)? = nil) {
        guard let token = KeychainUtils.getCurrentUserToken() else {
            return
        }
        guard let recId = userToSend.profile?.id ?? userToSend.doctor?.id else { return }
        let isDoc: Bool = userToSend.doctor != nil ? true : false
        ChatManager.shared.create(token: token, createModel: CreateChat(receiverId: recId, isDoctor: isDoc)) { (chatOp, error) in
            print("Create chat: \(String(describing: chatOp))")
            print("Create chat error: \(String(describing: error))")
            
            completion?(chatOp)
            ///guard let chat = chatOp else { return }
            ///self.setUpChat(chat)
        }
    }
}



// MARK: - Regulary updates
extension ChatsSinglManager {
    func startRegularyUpdate() {
        unreadedChatsTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            self.updateUnreadedChatsCount()
        }
    }
    
    func updateUnreadedChatsCount() {
        ChatManager.shared.unreadedChatsCount { (success, error) in
            //print("### unreadedChatsCount \(String(describing: success))")
            //print("### unreadedChatsCount error \(String(describing: error))")
            
            if let unreded = success {
                DispatchQueue.main.async {
                    self.appIconDelegate?.gotNewMessage(unreded.count)
                    self.tabBarDelegate?.gotNewMessage(unreded.count)
                    self.chatsIconDelegate?.gotNewMessage(unreded.count)
                }
            }
        }
    }
    
    func clearUnreadedCount() {
        self.appIconDelegate?.gotNewMessage(0)
        self.tabBarDelegate?.gotNewMessage(0)
        self.chatsIconDelegate?.gotNewMessage(0)
    }
}



// MARK: - Cache controll
extension ChatsSinglManager {
    func saveToCache() {
        //ChatCM.shared.cached = chatsList
    }
    
    func clearCache() {
        //ChatCM.shared.cached = []
    }
    
    func getFromCache() {
        //chatsList = ChatCM.shared.cached
    }
}


