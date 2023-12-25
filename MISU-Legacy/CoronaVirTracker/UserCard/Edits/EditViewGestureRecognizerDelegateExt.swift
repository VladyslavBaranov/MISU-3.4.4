//
//  EditViewGestureRecognizerDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension EditView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view as? UIControl) != nil || (touch.view as? UIScrollView) != nil {
            return false
        }
        if let view = gestureRecognizer.view as? EditView {
            let isKeyboard = view.isSubViewsFirstResponder(view: view)
            view.endEditing(true)
            return !isKeyboard && gestureRecognizer.view == touch.view
        }
        return true
    }
}
