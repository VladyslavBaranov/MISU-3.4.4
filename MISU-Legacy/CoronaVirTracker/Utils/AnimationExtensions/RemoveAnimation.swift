//
//  RemoveAnimation.swift
//  CoronaVirTracker
//
//  Created by WH ak on 09.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIView {
    func removeAllAnimations() {
        self.layer.removeAllAnimations()
        self.layoutIfNeeded()
    }
}
