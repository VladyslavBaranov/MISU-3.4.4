//
//  UIPresentViewGestureRecognizerDelegateExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/12/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UICustomPresentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = gestureRecognizer.view as? UICustomPresentViewController {
            let isKeyboard = view.isSubViewsFirstResponder(view: view)
            self.endEditing(true)
            if gestureRecognizer.view == touch.view {
                return !isKeyboard
            }
        }
        
        return gestureRecognizer.view == touch.view
    }
}
