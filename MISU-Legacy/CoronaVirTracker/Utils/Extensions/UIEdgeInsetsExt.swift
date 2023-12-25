//
//  UIEdgeInsetsExt.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 06.12.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    init(const: CGFloat) {
        self = .init(top: const, left: const, bottom: const, right: const)
    }
}
