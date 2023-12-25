//
//  UITextFieldExt.swift
//  WishHook
//
//  Created by KNimtur on 9/25/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import UIKit

extension UITextField {
    static func custom(placeholder: String = NSLocalizedString("Tap to edit", comment: ""),
                       fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular,
                       textColor: UIColor? = nil,
                       keyboardType: UIKeyboardType = .default, textContentType: UITextContentType? = nil) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = textColor ?? tf.textColor
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        tf.keyboardType = keyboardType
        tf.textContentType = textContentType
        return tf
    }
    
    func setBorder(color: CGColor, cornerRadius: CGFloat, borderWidth: CGFloat) {
        layer.borderColor = color
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layoutSubviews()
    }
    
    func setIcon(image: UIImage, frame: CGRect) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func clearEmpty() {
        if let txt = self.text, let last = txt.last, last == " " {
            self.text = String(txt.dropLast())
            clearEmpty()
        }
    }
}
