//
//  ChatGestureRecognizerExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 03.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension ChatVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view != sendButton && touch.view != messageView
    }
}
