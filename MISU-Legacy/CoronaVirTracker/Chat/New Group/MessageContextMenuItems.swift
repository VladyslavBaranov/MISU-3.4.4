//
//  MessageContextMenuItems.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 11.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum MessageContextMenuItems: String, CaseIterable {
    case copy = "Copy"
    
    var localized: String {
        get {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    var image: UIImage? {
        get {
            switch self {
            case .copy:
                return UIImage(named: "copyIcon")
            }
        }
    }
    
    func action(messageModel: Message) {
        switch self {
        case .copy:
            UIPasteboard.general.string = messageModel.text
        }
    }
    
    static func makeContextMenu(messageModel: Message) -> UIMenu {
        var actions = [UIAction]()
        MessageContextMenuItems.allCases.forEach { item in
            let action = UIAction(title: item.localized, image: item.image, identifier: nil, discoverabilityTitle: nil) { er in
                item.action(messageModel: messageModel)
            }
            actions.append(action)
        }
        
        //let cancel = UIAction(title: "Cancel", attributes: .destructive) { _ in}
        //actions.append(cancel)
        return UIMenu(title: "", children: actions)
    }
}
