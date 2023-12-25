//
//  GroupsManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 14.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct GroupsManager: BaseManagerHandler {
    private let router = Router<GroupsApi>()

    static let shared = GroupsManager()
    private init() {}
    
    func getAll(completion: @escaping (_ success: [GroupModel]?,_ error: HandledErrorModel?)->()) {
        router.request(.getAll) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func create(_ model: CreateGroupModel, completion: @escaping (_ success: GroupModel?,_ error: HandledErrorModel?)->()) {
        router.request(.create(parameters: model.getParams())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func invite(_ model: CreateGroupModel, completion: @escaping (_ success: GroupInviteModel?,_ error: HandledErrorModel?)->()) {
        router.request(.inviteUser(parameters: model.getParams(isIvite: true))) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func replyToInvite(_ m: GroupInviteModel, accept: Bool, completion: @escaping (_ success: GroupInviteModel?,_ error: HandledErrorModel?)->()) {
        var model = m
        if accept { model.accept() }
        else { model.decline() }
        router.request(.replyToInvite(id: model.id, parameters: model.encodeStatus())) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func getAllInvites(completion: @escaping (_ success: [GroupInviteModel]?,_ error: HandledErrorModel?)->()) {
        router.request(.getAllInvites) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func delete(groupId: Int, completion: @escaping Success200Completion) {
        router.request(.delete(id: groupId)) { data, response, error in
            handleResponse(data: data, response: response, error: error, success200Completion: completion)
        }
    }
    
    func delete(inviteId: Int, completion: @escaping Success200Completion) {
        router.request(.deleteInvite(id: inviteId) ) { data, response, error in
            handleResponse(data: data, response: response, error: error, success200Completion: completion)
        }
    }
    
    func delete(userId: Int, fromGroup gId: Int, completion: @escaping (_ success: GroupModel?,_ error: HandledErrorModel?)->()) {
        router.request(.update(id: gId, parameters: GroupModel.deleteUserParams(userId: userId))) { data, response, error in
            handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }
    
    func leaveGroup(completion: @escaping Success200Completion) {
        router.request(.leave) { data, response, error in
            handleResponse(data: data, response: response, error: error, success200Completion: completion)
        }
    }
}
