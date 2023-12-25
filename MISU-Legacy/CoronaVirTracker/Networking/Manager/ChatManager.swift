//
//  ChatManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 01.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct ChatManager: BaseManagerHandler {
    private let router = Router<ChatApi>()
    static let shared = ChatManager()
    private init() {}
    
    func unreadedChatsCount(completion: @escaping ResultCompletion<UnreadedChats>) {
        router.request(.unreadedChatsCount) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func readChat(id: Int, completion: @escaping Success200Completion) {
        router.request(.readMessagesIn(cId: id)) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, success200Completion: completion)
        }
    }
    
    func send(message: SendMessage, chatId: Int, completion: @escaping ResultCompletion<Message>) {
        let dataToSend = message.encodeToParameters()
        router.request(.sendMessage(chatId: chatId, param: dataToSend.params, files: dataToSend.files)) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getMessageIdsListOf(chatId: Int, completion: @escaping ResultCompletion<[Message]>) {
        router.request(.getMessagesIdsList(chatId: chatId)) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getMessageBy(id: Int, completion: @escaping ResultCompletion<[Message]>) -> URLSessionTask? {
        return router.requestWithReturn(.getMessageBy(id: id)) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getChatIdsList(completion: @escaping ResultCompletion<[Chat]>) {
        router.request(.getChatsIdsList) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getChatBy(id: Int, completion: @escaping ResultCompletion<[Chat]>) -> URLSessionTask? {
        return router.requestWithReturn(.getChatBy(id: id)) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func allPaginated(chatModel: ChatsThreadsPM, completion: @escaping ResultCompletion<ChatsThreadsPM>) {
        router.request(.allPaginated(params: chatModel.nextPageURLParams())) { data, response, error in
            handleResponse(data: data, response: response, error: error, successHandleCompletion: debugSuccessHandleCompletion(), failureCompletion: debugFailureHandleCompletion, completion: completion)
        }
    }
    
    func create(token: String, createModel: CreateChat, completion: @escaping ResultCompletion<Chat>) {
        router.request(.createChat(token: token, param: createModel.encodeToParameters())) {
            data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getAllChats(token: String, completion: @escaping (_ usersList: [ChatModel]?,_ error: ErrorModel?)->()) {
        router.request(.getAllChats(token: token)) {
            data, response, error in
            
            if let error = error {
                completion(nil, ErrorModel(error: error.localizedDescription,
                                           infoForUser: NetworkError.requestTimeOut.localizedRaw))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: NetworkError.noData.rawValue,
                                                   infoForUser: "Server error ...",
                                                   statusCode: response.statusCode))
                        return
                    }
                    
                    do {
                        //ErrorParser(data: responseData)
                        let apiResponse = try JSONDecoder().decode(ChatsThreadsModel.self, from: responseData)
                        completion(apiResponse.threads, nil)
                        //print("### New All: \(apiResponse.threads)")
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    ErrorParser(statusCode: response.statusCode, data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
    
    
    
    func getChat(chatId: Int, completion: @escaping (_ usersList: ChatModel?,_ error: ErrorModel?)->()) {
        router.request(.getChat(chatId: chatId)) {
            data, response, error in
            
            if let error = error {
                completion(nil, ErrorModel(error: error.localizedDescription,
                                           infoForUser: NetworkError.requestTimeOut.localizedRaw))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: NetworkError.noData.rawValue,
                                                   infoForUser: "Server error ...",
                                                   statusCode: response.statusCode))
                        return
                    }
                    
                    do {
                        //ErrorParser(data: responseData)
                        let apiResponse = try JSONDecoder().decode(ChatModel.self, from: responseData)
                        //print("### New one: \(apiResponse.participants)")
                        completion(apiResponse, nil)
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    ErrorParser(statusCode: response.statusCode, data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "123123123qwe", statusCode: response.statusCode))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
}

