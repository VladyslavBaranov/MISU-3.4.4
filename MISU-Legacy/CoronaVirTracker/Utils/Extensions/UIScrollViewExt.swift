//
//  UIScrollViewExt.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 21.01.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

extension UIScrollView {
    static func create(bounces: Bool = true) -> UIScrollView {
        let vw = UIScrollView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.bounces = bounces
        vw.alwaysBounceVertical = true
        vw.showsVerticalScrollIndicator = true
        vw.autoresizingMask = .flexibleHeight
        return vw
    }
}
