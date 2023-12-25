//
//  ColorAnimation.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 1/24/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateColor(_ color: UIColor?, duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.backgroundColor = color
        }, completion: completion)
    }
}
