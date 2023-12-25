//
//  ChatApi.swift
//  CoronaVirTracker
//
//  Created by WH ak on 01.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum ChatApi {
    case getAllChats(token: String)
    case createChat(token: String, param: Parameters)
    case getChat(chatId: Int)
    case sendMessage(chatId: Int, param: Parameters, files: Files)
    case allPaginated(params: Parameters)
    
    case getChatsIdsList
    case getChatBy(id: Int)
    case getMessagesIdsList(chatId: Int)
    case getMessageBy(id: Int)
    case readMessagesIn(cId: Int)
    case unreadedChatsCount
}

extension ChatApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.messages) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getAllChats, .allPaginated: return "list/"
        case .createChat: return "create_chat/"
        case .getChat(let id): return "chat/\(id)/"
        case .sendMessage(let chatId, _, _): return "send_message_api/\(chatId)/"
        case .getChatsIdsList: return "threads/id"
        case .getChatBy(let id): return "threads/\(id)"
        case .getMessagesIdsList(let chatId): return "message/id/\(chatId)"
        case .getMessageBy(let id): return "message/\(id)"
        case .readMessagesIn(let id): return "chat/\(id)/read"
        case .unreadedChatsCount: return "threads/unread"
        }
        
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getAllChats, .getChat, .allPaginated,
             .getChatsIdsList, .getChatBy, .getMessagesIdsList,
             .getMessageBy, .readMessagesIn, .unreadedChatsCount:
            return .get
        case .createChat, .sendMessage: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .allPaginated(let params):
            return .requestURL(urlParameters: params)
        case .getAllChats, .getChat: return .request
        case .createChat(_, let param):
            return .requestBodyJson(bodyParameters: param)
        case .sendMessage(_, let param, let files):
            return .requestBodyMultiPartFormDataFiles(bodyParameters: param, files: files)
        case .getChatsIdsList, .getChatBy, .getMessagesIdsList, .getMessageBy,
             .readMessagesIn, .unreadedChatsCount:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getAllChats(let token), .createChat(let token, _):
            return TypeHeaders.create(token: token)
        case .getChat, .sendMessage, .allPaginated,
             .getChatsIdsList, .getChatBy, .getMessagesIdsList,
             .getMessageBy, .readMessagesIn, .unreadedChatsCount:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        }
    }
}
