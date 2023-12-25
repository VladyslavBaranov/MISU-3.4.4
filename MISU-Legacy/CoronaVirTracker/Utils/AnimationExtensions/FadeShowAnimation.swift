//
//  FadeShowAnimation.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 1/23/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateFade(alpha alph: CGFloat = 0.0, duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alph
        }, completion: completion)
    }
    
    func animateShow(duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }
}
