//
//  ShakeAnimation.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 1/24/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateShake(intensity: Double, duration: Double, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        
        let base: [Double] = [-3.0, 3.0, -2.0, 2.0, -1.0, 1.0, 0.0]
        animation.values = base.map{ $0 * intensity }
        
        CATransaction.setCompletionBlock(completion)
        
        self.layer.add(animation, forKey: "shake")
    }
}
