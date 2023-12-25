//
//  MoveAnimation.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 1/28/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateMove(x: CGFloat = 0, y: CGFloat, duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(translationX: x, y: y)
        }, completion: completion)
    }
    
    func animateMoveFrameOrigin(x: CGFloat, y: CGFloat, duration: Double, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.frame.origin = .init(x: x, y: y)
        }, completion: completion)
    }
}
