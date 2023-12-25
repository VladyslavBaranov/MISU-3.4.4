//
//  ModalMessageView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 27.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ModalMessageView: UIView {
    let titleLabel: UILabel = .createTitle(text: "|", fontSize: 14, color: .black, alignment: .left)
    
    init(_ titleText: String, type: ModalMessagesController.MessageType) {
        super.init(frame: .zero)
        titleLabel.text = titleText
        
        switch type {
        case .success:
            self.backgroundColor = UIColor.appDefault.green
            titleLabel.textColor = .white
        case .usual:
            self.backgroundColor = .white
            titleLabel.textColor = .darkText
        case .error:
            self.backgroundColor = UIColor.appDefault.red
            titleLabel.textColor = .white
        case .warning:
            self.backgroundColor = .systemYellow
            titleLabel.textColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(titleLabel)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setCustomCornerRadius()
        self.addCustomShadow(shadowOffset: CGSize(width: 0, height: 1))
        guard let parent = self.superview else { return }
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: standartInset).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -standartInset).isActive = true
        self.topAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.topAnchor, constant: standartInset).isActive = true
        
        titleLabel.numberOfLines = 42
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: standartInset).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -standartInset).isActive = true
        self.layoutIfNeeded()
    }
}

extension ModalMessageView {
    final func show() {
        guard let appDelegate = UIApplication.shared.delegate else { return }
        guard let window = appDelegate.window else { return }
        
        if let fullFrame = window?.frame { self.frame = fullFrame }
        
        self.animateFade(duration: 0)
        titleLabel.animateFade(duration: 0)
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)
        setUpView()
        hideAnimation(0.0)
        self.animateShow(duration: 0)
        titleLabel.animateShow(duration: 0)
        
        showAnimation(0.3)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            if self.isTouching ?? false { return }
            self.hide()
        }
    }
    
    private func showAnimation(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateShow(duration: duration)
        self.animateMove(y: 0, duration: duration, completion: completion)
    }
    
    private func hideAnimation(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateFade(duration: duration)
        self.animateMove(y: -self.frame.height-standartInset*2, duration: duration, completion: completion)
    }
    
    func hide() {
        self.hideAnimation(0.3) { _ in
            self.removeFromSuperview()
        }
    }
}



// MARK: - Drag and move
extension ModalMessageView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let loc = touches.first?.location(in: self.superview) else { return }
        touchBeganLocation = loc
        isTouching = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currLoc = touches.first?.location(in: self.superview), let beganLoc = touchBeganLocation else { return }
        
        let y = currLoc.y - beganLoc.y
        self.animateMove(y: y, duration: 0.0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hide()
        isTouching = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hide()
        isTouching = false
    }
}
