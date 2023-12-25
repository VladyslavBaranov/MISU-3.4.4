//
//  UIUnderLinedTextField.swift
//  CoronaVirTracker
//
//  Created by WH ak on 27.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class UIUnderLinedTextField: UITextField {
    @IBInspectable var contentEgesInsets: UIEdgeInsets = .init(top: 8, left: 2, bottom: 8, right: 2)
    var deleteBackwardDelegate: DeleteBackwardDelegate?
    
    var underLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var underLineHeightAnchor: NSLayoutConstraint?
    
    var underLineHeight: CGFloat {
        get {
            guard let height = underLineHeightAnchor?.constant else { return 0 }
            return height
        }
        
        set(newValue) {
            underLineHeightAnchor?.constant = newValue
        }
    }
    
    init(fontSize: CGFloat = 16, returnKey: UIReturnKeyType = .next, underlineColor: UIColor = .init(hexString: "#E5E5E5"), underlineHeight: CGFloat = 2) {
        super.init(frame: CGRect.zero)
        
        setUpTextField(fontSize: fontSize, returnKey: returnKey)
        setUpUnderlineView(underlineColor: underlineColor, underlineHeight: underlineHeight)
    }
    
    func setUpTextField(fontSize: CGFloat = 16, returnKey: UIReturnKeyType = .next) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.borderStyle = .none
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.returnKeyType = returnKeyType
    }
    
    func setUpUnderlineView(underlineColor: UIColor = .init(hexString: "#E5E5E5"), underlineHeight: CGFloat = 2) {
        underLineView.backgroundColor = underlineColor
        underLineView.originColor = underlineColor
        underLineView.tempColor = underlineColor
        self.addSubview(underLineView)
        underLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        underLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        underLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        let h = underLineView.heightAnchor.constraint(equalToConstant: underlineHeight)
        underLineHeightAnchor = h
        h.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - Animations
extension UIUnderLinedTextField {
    func alertAnimation(color: UIColor = UIColor.appDefault.red, duration: Double = 0.3) {
        underLineView.tempColor = underLineView.backgroundColor
        underLineView.animateColor(color, duration: 0.1) { _ in
            self.animateShake(intensity: 3, duration: duration)
            self.underLineView.animateShake(intensity: 3, duration: duration) {
                self.underLineView.animateColor(self.underLineView.tempColor, duration: duration)
            }
        }
    }
    
    func setSelected(color: UIColor = .lightGray, duration: Double = 0.1) {
        underLineView.animateColor(color, duration: duration)
    }
    
    func setUnSelected(color: UIColor? = nil, duration: Double = 0.1) {
        if color == nil {
            underLineView.animateColor(underLineView.originColor, duration: duration)
            return
        }
        underLineView.animateColor(color, duration: duration)
    }
}



// MARK: - UITextField overrides
extension UIUnderLinedTextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentEgesInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentEgesInsets)
    }
    
    override func deleteBackward() {
        deleteBackwardDelegate?.textFieldDidDeleteBackward?(textField: self)
        super.deleteBackward()
    }
}



// MARK: - deleteBackward protocol
@objc protocol DeleteBackwardDelegate {
    @objc optional func textFieldDidDeleteBackward(textField: UITextField)
}
