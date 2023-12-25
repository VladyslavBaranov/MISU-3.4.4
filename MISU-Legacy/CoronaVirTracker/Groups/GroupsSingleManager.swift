//
//  GroupsSingleManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 14.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

@objc protocol GroupsDelegate {
    @objc optional func groupsDidUpdate(manager: GroupsSingleManager)
    func groupDidDeleted()
}

class GroupsSingleManager: NSObject {
    static let shared: GroupsSingleManager = .init()
    private override init() {
        super.init()
        getAll()
    }
    
    var groups: [GroupModel] = []
    var invites: [GroupInviteModel] = []
    
    var delegate: GroupsDelegate?
}



// MARK: - Actions
extension GroupsSingleManager {
    func familyProfileButtonAction(_ controller: UIViewController?) {
        if groups.first != nil {
            goToGroupVC(controller)
            return
        }
        
        let vc = InviteUserToGroupVC { [self] newGroup in
            addGroup(newGroup)
            goToGroupVC(controller)
        }
        controller?.present(vc, animated: true)
    }
    
    func goToGroupVC(_ controller: UIViewController?) {
        guard let gr = groups.first else { return }
        let vc = GroupVC(group: gr)
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - Methods
extension GroupsSingleManager {
    func update() {
        getAll()
        getInvites()
    }
    
    func addGroup(_ newGroup: GroupModel?) {
        guard let gr = newGroup else { return }
        
        if let gId = groups.firstIndex(where: {$0.id == gr.id}) {
            groups[gId] = gr
        } else {
            groups.append(gr)
        }
        
        DispatchQueue.main.async { [self] in
            delegate?.groupsDidUpdate?(manager: self)
        }
    }
    
    func getInvites(groupId: Int) -> [GroupInviteModel] {
        var gInvites: [GroupInviteModel] = []
        invites.forEach { invite in
            if invite.groupId == groupId,
               invite.sender?.id == UCardSingleManager.shared.user.id,
               invite.status == nil {
                gInvites.append(invite)
            }
        }
        
        return gInvites
    }
}



// MARK: - Requests Methods
extension GroupsSingleManager {
    func leaveGroup() {
        GroupsManager.shared.leaveGroup() { [self] (success, errorOp) in
            if success {
                print("Leave group success")
                DispatchQueue.main.async {
                    self.delegate?.groupDidDeleted()
                }
                update()
            }
            if let error = errorOp {
                print("delete user ERROR: \n\(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
    
    func delete(userId: Int, fromGroup gId: Int) {
        GroupsManager.shared.delete(userId: userId, fromGroup: gId) { [self] (groupOP, errorOp) in
            if let group = groupOP {
                print("delete user success \(group.id)")
                addGroup(group)
            }
            if let error = errorOp {
                print("delete user ERROR: \n\(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
    
    func deleteInvite(id: Int) {
        GroupsManager.shared.delete(inviteId: id) { [self] (success, errorOp) in
            if success {
                print("deleteInvite success")
                update()
            }
            if let error = errorOp {
                print("deleteInvite ERROR: \n\(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
    
    func deleteGroup(id: Int) {
        GroupsManager.shared.delete(groupId: id) { [self] (success, errorOp) in
            if success {
                print("DeleteGroup success")
                DispatchQueue.main.async {
                    self.delegate?.groupDidDeleted()
                }
                update()
            }
            if let error = errorOp {
                print("DeleteGroup ERROR: \n\(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
    
    func getAll() {
        GroupsManager.shared.getAll { [self] (groupsOp, errorOp) in
            if let grps = groupsOp {
                groups = grps
                print("Got groups: \n\(grps.count)")
                DispatchQueue.main.async { [self] in
                    delegate?.groupsDidUpdate?(manager: self)
                }
            }
            if let error = errorOp {
                print("Got groups ERROR: \n\(error)")
            }
        }
    }
    
    func getInvites() {
        GroupsManager.shared.getAllInvites{ [self] (invitesOp, errorOp) in
            if let invts = invitesOp {
                invites = invts
                print("Got invites: \n\(invts.count)")
                DispatchQueue.main.async { [self] in
                    delegate?.groupsDidUpdate?(manager: self)
                }
            }
            if let error = errorOp {
                print("Got groups ERROR: \n\(error)")
            }
        }
    }
}
