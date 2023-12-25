//
//  ResetTransformAnimation.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 2/26/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateResetToIdentity(duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = .identity
        }, completion: completion)
    }
}
