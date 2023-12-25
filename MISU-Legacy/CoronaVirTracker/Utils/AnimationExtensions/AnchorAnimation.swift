//
//  ConstraintAnimation.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/4/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIView {
    func animateConstraint(_ constraint: NSLayoutConstraint? = nil, constant: CGFloat? = nil, duration: Double, completion: ((Bool) -> Void)? = nil) {
        guard let const = constant else { return }
        UIView.animate(withDuration: duration, animations: {
            constraint?.constant = const
            self.superview?.layoutIfNeeded()
        }, completion: completion)
    }
    
    func animateChangeConstraints(deactivate unConstraint: NSLayoutConstraint? = nil, activate acConstraint: NSLayoutConstraint? = nil, duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3) {
            unConstraint?.isActive = false
            acConstraint?.isActive = true
            self.superview?.layoutIfNeeded()
        }
    }
}
