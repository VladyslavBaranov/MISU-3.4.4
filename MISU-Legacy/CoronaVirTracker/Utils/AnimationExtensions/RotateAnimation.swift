//
//  RotateAnimation.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 04.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIView {
    func animateRotate(duration: Double, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 5)
        rotation.duration = duration
        CATransaction.setCompletionBlock(completion)
        self.layer.add(rotation, forKey: "rotationAnimation")
        CATransaction.commit()
    }
}
