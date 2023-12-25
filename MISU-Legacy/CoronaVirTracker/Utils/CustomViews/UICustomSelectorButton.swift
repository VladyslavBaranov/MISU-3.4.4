//
//  UICustomSelectorButton.swift
//  CoronaVirTracker
//
//  Created by WH ak on 02.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - delete protocol
@objc protocol UICustomSelectorButtonDelegate {
    @objc optional func selectorButtonDidTap(_ selectorButton: UICustomSelectorButton)
}

class UICustomSelectorButton: UIView {
    let imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 10)
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 18)
        lb.originFontSize = lb.font.pointSize
        lb.textAlignment = .center
        lb.numberOfLines = 5
        return lb
    }()
    
    var customDelegate: UICustomSelectorButtonDelegate?
    
    var isSelected: Bool? {
        didSet {
            guard let selected = isSelected else { return }
            if selected {
                titleLabel.animateScaleTransform(x: 1.1, y: 1.1, duration: 0.1)
                addCustomBorder(radius: 5, color: .appDefault.green)
            } else {
                titleLabel.animateScaleTransform(x: 1, y: 1, duration: 0.1)
                addCustomBorder(radius: 0, color: .clear)
            }
        }
    }
    
    init(image: UIImage? = UIImage(named: "ImPatient"),
         text: String = NSLocalizedString("I'm a patient", comment: ""),
         fontSize: CGFloat = 18) {
        super.init(frame: .zero)
        
        imageView.image = image
        titleLabel.text = text
        titleLabel.font = .systemFont(ofSize: fontSize)
        titleLabel.originFontSize = titleLabel.font.pointSize
        
        setUpView()
    }
    
    func setUpView() {
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.setCustomCornerRadius()
        self.addCustomShadow()
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 100), for: .vertical)
        
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
    }
    
    func selected() {
        if isSelected ?? false {
            isSelected = false
        } else {
            isSelected = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View touches overrides
extension UICustomSelectorButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if isTouchMoveOut(touch: touch) {
            isTouchMovedOut = true
            self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        if !isTouchMovedOut {
            selected()
            customDelegate?.selectorButtonDidTap?(self)
        }
        isTouchMovedOut = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        if !isTouchMovedOut {
            selected()
            customDelegate?.selectorButtonDidTap?(self)
        }
        isTouchMovedOut = false
    }
}
