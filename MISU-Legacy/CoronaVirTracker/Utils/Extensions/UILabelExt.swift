//
//  UILabelExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UILabel {
    static func createTitle(text: String = "label",
                            fontSize: CGFloat = 14,
                            weight: UIFont.Weight = .regular,
                            color: UIColor = .black,
                            alignment: NSTextAlignment = .left,
                            monospacedDigit: Bool = false,
                            numberOfLines: Int = 1,
                            isCopyable: Bool = false) -> UILabel {
        let tl = isCopyable ? CopyableLabel() : UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = alignment
        if monospacedDigit {
            tl.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: weight)
        } else {
            tl.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        }
        tl.textColor = color
        tl.text = text
        tl.numberOfLines = numberOfLines
        tl.sizeToFit()
        return tl
    }
}
