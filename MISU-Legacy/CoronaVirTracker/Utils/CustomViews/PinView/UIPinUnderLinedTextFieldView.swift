//
//  UIPinUnderLinedTextFieldView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 30.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

@objc protocol UIPinUnderLinedTextFieldViewDelegate {
    @objc optional func pinTextFieldDidEndFilling(text: String)
}

class UIPinUnderLinedTextFieldView: UIView {
    var underLineTextFields: [UIUnderLinedTextField] = []
    var numberOfCharacters = 6
    var separationSize: CGFloat = 16
    
    var pinDelegate: UIPinUnderLinedTextFieldViewDelegate?
    
    var text: String {
        get {
            var txt = ""
            for txtFld in underLineTextFields {
                guard let t = txtFld.text else { break }
                txt += t
            }
            return txt
        }
    }
    
    init(length: Int = 6, fontSize: CGFloat = 16, returnKey: UIReturnKeyType = .done, underlineColor: UIColor = .init(hexString: "#E5E5E5"), underlineHeight: CGFloat = 2) {
        super.init(frame: CGRect.zero)
        
        self.numberOfCharacters = length
        
        setUpView()
        setUpTextFields(fontSize: fontSize, returnKey: returnKey, underlineColor: underlineColor, underlineHeight: underlineHeight)
    }
    
    func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: standartInset/2).isActive = true
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: standartInset/2).isActive = true
    }
    
    func setUpTextFields(fontSize: CGFloat, returnKey: UIReturnKeyType, underlineColor: UIColor, underlineHeight: CGFloat) {
        var prevView: UIView = self
        (0...numberOfCharacters-1).forEach { index in
            let txtView = UIUnderLinedTextField(fontSize: fontSize, returnKey: returnKey,
                                                underlineColor: underlineColor, underlineHeight: underlineHeight)
            txtView.translatesAutoresizingMaskIntoConstraints = false
            txtView.textContentType = .oneTimeCode
            txtView.keyboardType = .numberPad
            txtView.textAlignment = .center
            txtView.delegate = self
            txtView.deleteBackwardDelegate = self
            txtView.tag = index
            txtView.placeholder = "•"
            underLineTextFields.append(txtView)
            
            self.addSubview(underLineTextFields[index])
            if prevView == self {
                underLineTextFields[index].leadingAnchor.constraint(equalTo: prevView.leadingAnchor).isActive = true
                underLineTextFields[index].topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                underLineTextFields[index].bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            } else {
                underLineTextFields[index].leadingAnchor.constraint(equalTo: prevView.trailingAnchor, constant: separationSize).isActive = true
                underLineTextFields[index].centerYAnchor.constraint(equalTo: prevView.centerYAnchor).isActive = true
            }
            
            let w = "0".getSize(fontSize: fontSize).width * 3
            underLineTextFields[index].widthAnchor.constraint(equalToConstant: w).isActive = true
            
            prevView = underLineTextFields[index]
        }
        underLineTextFields.last?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View touches overrides
extension UIPinUnderLinedTextFieldView {
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        underLineTextFields.last?.becomeFirstResponder()
    }
}

// MARK: - View animations
extension UIPinUnderLinedTextFieldView {
    func alertAnimation(color: UIColor? = UIColor.appDefault.red, duration: Double = 0.3) {
        for tf in underLineTextFields {
            tf.underLineView.tempColor = tf.underLineView.backgroundColor
            tf.underLineView.animateColor(color, duration: 0.1)
        }
        self.animateShake(intensity: 3, duration: duration) {
            for tf in self.underLineTextFields {
                tf.underLineView.animateColor(tf.underLineView.tempColor, duration: duration)
            }
        }
    }
    
    func doneAnimation(completion: (() -> Void)? = nil, color: UIColor? = UIColor.appDefault.green, duration: Double = 0.1) {
        guard let ftf = underLineTextFields.first else { return }
        doneAnimNext(textField: ftf, color: color, duration: duration, completion: completion)
    }
    
    private func doneAnimNext(textField: UIUnderLinedTextField, color: UIColor?, duration: Double, completion: (() -> Void)?) {
        textField.underLineView.animateColor(color, duration: duration) { _ in
            guard let next = textField.superview?.viewWithTag(textField.tag+1) as? UIUnderLinedTextField else {
                completion?()
                return
            }
            self.doneAnimNext(textField: next, color: color, duration: duration, completion: completion)
        }
    }
}
