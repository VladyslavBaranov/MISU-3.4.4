//
//  ModalMessagesController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 27.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ModalMessagesController {
    static let shared = ModalMessagesController()
    private init() {}
    
    private var messageView: ModalMessageView?
    
    enum MessageType {
        case success
        case usual
        case warning
        case error
    }
    
    func show(message: String, type: MessageType) {
        DispatchQueue.main.async {
            self.messageView?.hide()
            self.messageView = ModalMessageView(message, type: type)
            self.messageView?.show()
        }
    }
}
