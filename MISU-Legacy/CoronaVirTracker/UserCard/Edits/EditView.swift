//
//  EditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 08.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - View Parameters
class EditView: UIView {
    let contentView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = UIColor.white
        vw.isUserInteractionEnabled = true
        vw.cornerRadius = 10
        return vw
    }()
    
    let saveButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        bt.backgroundColor = UIColor.white
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        bt.cornerRadius = 10
        return bt
    }()
    
    let cancelButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        bt.setTitleColor(UIColor.appDefault.red, for: .normal)
        bt.backgroundColor = UIColor.white
        bt.cornerRadius = 10
        return bt
    }()
    
    var customBottomAnchorToSave: NSLayoutConstraint? = nil
    var customBottomAnchorToCancel: NSLayoutConstraint? = nil
    
    var completionAction: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.frame = frame
        
        self.addTapRecognizer(self, action: #selector(cancelButtonAction))
        self.gestureRecognizers?.first?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initSetUp()
        setUpAdditionalViews()
        if saveButton.isHidden {
            self.animateChangeConstraints(deactivate: customBottomAnchorToSave, activate: customBottomAnchorToCancel, duration: 0.0)
        }
    }
    
    private func initSetUp() {
        self.addSubview(contentView)
        self.addSubview(saveButton)
        self.addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        
        //contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -standartInset*3).isActive = true
        contentView.customHeightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: standartInset*2)
        contentView.customHeightAnchorConstraint?.priority = UILayoutPriority(rawValue: 900)
        contentView.customHeightAnchorConstraint?.isActive = true
        
        //contentView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: standartInset).isActive = true
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: standartInset).isActive = true
        customBottomAnchorToSave = contentView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -standartInset/2)
        customBottomAnchorToSave?.isActive = true
        customBottomAnchorToCancel = contentView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -standartInset/2)
        customBottomAnchorToCancel?.isActive = false
        
        contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        
        saveButton.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: standartInset*3).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -standartInset/2).isActive = true
        
        cancelButton.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: standartInset*3).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cancelButton.customBottomAnchorConstraint = cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -standartInset)
        cancelButton.customBottomAnchorConstraint?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View Show Hide Methods
extension EditView {
    final func show(completion: ((Bool) -> Void)? = nil) {
        self.completionAction = completion
        moveDown(0.0)
        
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        guard let window = appDelegate.window else {
            return
        }
        self.frame = window?.frame ?? .zero
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)
        
        moveUp(0.3)
    }
    
    private func moveUp(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateShow(duration: duration)
        contentView.animateMove(y: 0, duration: duration)
        saveButton.animateMove(y: 0, duration: duration)
        cancelButton.animateMove(y: 0, duration: duration, completion: completion)
    }
    
    private func moveDown(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateFade(duration: duration)
        contentView.animateMove(y: self.frame.height, duration: duration)
        saveButton.animateMove(y: self.frame.height, duration: duration)
        cancelButton.animateMove(y: self.frame.height, duration: duration, completion: completion)
    }
}



// MARK: - Buttons Actions
extension EditView {
    @objc final func saveButtonAction() {
        if !saveAction() { return }
        completionAction?(true)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    final func saveActionAfterRequest() {
        completionAction?(true)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc final func cancelButtonAction() {
        if !cancelAction() { return }
        //completionAction?(false)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
}



// MARK: - Methods to override
extension EditView {
    // override this methods to implement some actions to save / cancel / other views setup
    
    @objc func setUpAdditionalViews() {}
    
    @objc func keyboardWillShowAction(keyboardFrame: CGRect) {}
    @objc func keyboardWillHideAction() {}
    
    @objc func saveAction() -> Bool { return true }
    
    @objc func cancelAction() -> Bool { return true }
}



// MARK: - Keyboard notifications
extension EditView {
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

