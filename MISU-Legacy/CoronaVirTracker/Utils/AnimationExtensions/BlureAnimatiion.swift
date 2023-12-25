//
//  BlureAnimatiion.swift
//  CoronaVirTracker
//
//  Created by WH ak on 02.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateBlure(duration: Double, completion: ((Bool) -> Void)? = nil) {
        let overlay = UIVisualEffectView()
        overlay.frame = self.frame
        self.addSubview(overlay)
        UIView.animate(withDuration: duration, animations: {
            overlay.effect = UIBlurEffect(style: .light)
        }, completion: completion)
    }
}
