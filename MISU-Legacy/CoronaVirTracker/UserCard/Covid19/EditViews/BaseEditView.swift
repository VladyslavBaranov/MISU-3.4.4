//
//  BaseEditView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 10.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

@objc protocol BaseEditViewDelegate {
    @objc optional func willShow(editView: BaseEditView)
    @objc optional func didShow(editView: BaseEditView)
    
    @objc optional func willHide(editView: BaseEditView)
    @objc optional func didHide(editView: BaseEditView)
}



// MARK: - View Parameters
class BaseEditView: UIView {
    let mainStack: UIStackView = .createCustom(axis: .vertical)
    let contentView: UIView = .createCustom(bgColor: .white, cornerRadius: 10)
    let saveButton: UIButton = .createCustom(title: NSLocalizedString("Save", comment: ""), color: .white,
                                             fontSize: 16, weight: .medium, textColor: .systemBlue,
                                             shadow: false, btnType: .system)
    let cancelButton: UIButton = .createCustom(title: NSLocalizedString("Cancel", comment: ""), color: .white,
                                               fontSize: 16, textColor: UIColor.appDefault.red,
                                               shadow: false, btnType: .system)
    var completionAction: ((Bool) -> Void)?
    
    var delegate: BaseEditViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        setUp()
    }
    
    @objc func setUp() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.addTapRecognizer(self, action: #selector(cancelButtonAction))
        self.gestureRecognizers?.first?.delegate = self
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipe.direction = .down
        addGestureRecognizer(swipe)
        isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.addSubview(mainStack)
        mainStack.addArrangedSubview(contentView)
        mainStack.addArrangedSubview(saveButton)
        mainStack.addArrangedSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        
        [contentView, saveButton, cancelButton].forEach { vw in
            vw.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        }
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: standart24Inset).isActive = true
        mainStack.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: standartInset).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standartInset).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
        mainStack.customBottomAnchorConstraint = mainStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -standartInset)
        mainStack.customBottomAnchorConstraint?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View Show Hide Methods
extension BaseEditView {
    @objc func show(parentView: UIView? = nil, completion: ((Bool) -> Void)? = nil) {
        self.completionAction = completion
        moveDown(0.0)
        if let pv = parentView {
            self.frame = pv.frame
            pv.addSubview(self)
            pv.bringSubviewToFront(self)
            pv.endEditing(true)
        } else {
            guard let window = UIApplication.shared.delegate?.window else { return }
            self.frame = window?.frame ?? .zero
            window?.addSubview(self)
            window?.bringSubviewToFront(self)
            window?.endEditing(true)
        }
        moveUp(0.3)
    }
    
    func moveUp(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        delegate?.willShow?(editView: self)
        
        self.animateShow(duration: duration)
        mainStack.animateMove(y: 0, duration: duration, completion: completion)
        
        delegate?.didShow?(editView: self)
    }
    
    func moveDown(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        delegate?.willHide?(editView: self)
        
        self.animateFade(duration: duration)
        mainStack.animateMove(y: self.frame.height, duration: duration, completion: completion)
        
        delegate?.didHide?(editView: self)
    }
}



// MARK: - Buttons Actions
extension BaseEditView {
    @objc func saveButtonAction(_ sender: UIButton) {
        //print("### saveButtonAction")
        completionAction?(true)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func cancelButtonAction() {
        //print("### cancelButtonAction")
        completionAction?(false)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .down {
            cancelButtonAction()
        }
    }
}



// MARK: - Methods to override
extension BaseEditView {
    @objc func keyboardWillShowAction(keyboardFrame: CGRect) {}
    @objc func keyboardWillHideAction() {}
}



// MARK: - Keyboard notifications
extension BaseEditView {
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        keyboardWillShowAction(keyboardFrame: keyboardFrame)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardWillHideAction()
    }
}



// MARK: - GestureRecognizer Delegate
extension BaseEditView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view as? UIControl) != nil || (touch.view as? UIScrollView) != nil {
            return false
        }
        if let view = gestureRecognizer.view as? BaseEditView {
            let isKeyboard = view.isSubViewsFirstResponder(view: view)
            view.endEditing(true)
            return !isKeyboard && gestureRecognizer.view == touch.view
        }
        return true
    }
}

