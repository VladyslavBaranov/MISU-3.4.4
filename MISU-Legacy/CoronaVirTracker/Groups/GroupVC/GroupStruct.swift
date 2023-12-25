//
//  GroupStruct.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum GroupStruct: Int, CaseIterable {
    case info = 0
    case participants = 1
    case pending = 2
    
    var description: String {
        get { return String(describing: self) }
    }
    
    var localization: String {
        get { return NSLocalizedString(self.description, comment: "") }
    }
    
    func makeContextMenu(id: Int, groupId: Int) -> UIMenu? {
        switch self {
        case .participants:
            return ParticipantsContextMenuStruct.makeContextMenu(userId: id, groupId: groupId)
        case .pending:
            return PendingContextMenuStruct.makeContextMenu(inviteId: id)
        default:
            return nil
        }
    }
}



// MARK: - Participants
extension GroupStruct {
    enum PendingContextMenuStruct: CaseIterable {
        case delete
        
        var localized: String {
            get {
                switch self {
                case .delete: return NSLocalizedString("Delete invite", comment: "")
                }
            }
        }
        
        var image: UIImage? {
            get {
                switch self {
                case .delete: return UIImage(named: "deleteIcon72px")
                }
            }
        }
        
        func action(inviteId: Int) {
            switch self {
            case .delete: return
                GroupsSingleManager.shared.deleteInvite(id: inviteId)
            }
        }
        
        var attributes: UIMenuElement.Attributes {
            get {
                switch self {
                case .delete: return .destructive
                }
            }
        }
        
        static func makeContextMenu(inviteId: Int) -> UIMenu {
            var actions = [UIAction]()
            PendingContextMenuStruct.allCases.forEach { item in
                let action = UIAction(title: item.localized, image: item.image, identifier: nil, discoverabilityTitle: nil, attributes: item.attributes) { er in
                    item.action(inviteId: inviteId)
                }
                actions.append(action)
            }
            return UIMenu(title: "", children: actions)
        }
    }
}



// MARK: - Participants
extension GroupStruct {
    enum ParticipantsContextMenuStruct: CaseIterable {
        case delete
        
        var localized: String {
            get {
                switch self {
                case .delete: return NSLocalizedString("Delete participant", comment: "")
                }
            }
        }
        
        var image: UIImage? {
            get {
                switch self {
                case .delete: return UIImage(named: "deleteIcon72px")
                }
            }
        }
        
        func action(userId: Int, fromGroup gId: Int) {
            switch self {
            case .delete: return
                GroupsSingleManager.shared.delete(userId: userId, fromGroup: gId)
            }
        }
        
        var attributes: UIMenuElement.Attributes {
            get {
                switch self {
                case .delete: return .destructive
                }
            }
        }
        
        static func makeContextMenu(userId: Int, groupId: Int) -> UIMenu {
            var actions = [UIAction]()
            ParticipantsContextMenuStruct.allCases.forEach { item in
                let action = UIAction(title: item.localized, image: item.image, identifier: nil, discoverabilityTitle: nil, attributes: item.attributes) { er in
                    item.action(userId: userId, fromGroup: groupId)
                }
                actions.append(action)
            }
            return UIMenu(title: "", children: actions)
        }
    }
}
