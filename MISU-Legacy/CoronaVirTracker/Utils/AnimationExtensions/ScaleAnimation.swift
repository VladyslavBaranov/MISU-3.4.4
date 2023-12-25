//
//  ScaleAnimation.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 1/30/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateScaleTransform(x: CGFloat = 0, y: CGFloat = 0, duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: x, y: y)
        }, completion: completion)
    }
    
    func animateScaleFrame(x: CGFloat = 0, y: CGFloat = 0, duration: Double, completion: ((Bool) -> Void)? = nil) {
        var width = x
        var height = y
        if let orgSz = originSize {
            width = orgSz.width + x
            height = orgSz.height + y
        } else {
            originSize = self.frame.size
            width += self.frame.size.width
            height += self.frame.size.height
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.frame.size.width = width
            self.frame.size.height = height
        }, completion: completion)
    }
}
