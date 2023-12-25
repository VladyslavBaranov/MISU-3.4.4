//
//  UICustomPresentViewController.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/12/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Parametes
class UICustomPresentViewController: UIView {
    let backgroundView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = UIColor.white
        vw.isUserInteractionEnabled = true
        vw.setRoundedParticly(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10)
        return vw
    }()
    
    let contentView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = UIColor.clear
        vw.isUserInteractionEnabled = true
        return vw
    }()
    
    let navigationView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = UIColor.init(hexString: "#EFEFF4")
        vw.addShadow(radius: 1, offset: CGSize.zero, opacity: 1, color: .black)
        return vw
    }()
    
    let doneButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        bt.sizeToFit()
        return bt
    }()
    
    let cancelButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        bt.setTitleColor(UIColor.init(hexString: "#EE3838"), for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bt.sizeToFit()
        return bt
    }()
    
    let titleLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .center
        tl.textColor = UIColor.black
        tl.font = UIFont.systemFont(ofSize: 16)
        tl.text = "Title"
        return tl
    }()
    
    var contentEdgeInsets: UIEdgeInsets {
        set {
            contentView.customTopAnchorConstraint?.constant = newValue.top
            contentView.customLeadingAnchorConstraint?.constant = newValue.left
            contentView.customBottomAnchorConstraint?.constant = newValue.bottom
            contentView.customTrailingAnchorConstraint?.constant = newValue.right
        }
        get {
            return UIEdgeInsets(top: contentView.customTopAnchorConstraint?.constant ?? 0,
                                left: contentView.customLeadingAnchorConstraint?.constant ?? 0,
                                bottom: contentView.customBottomAnchorConstraint?.constant ?? 0,
                                right: contentView.customTrailingAnchorConstraint?.constant ?? 0)
        }
    }
    
    let topDragInset: CGFloat = 16*3
    let bottomDragInset: CGFloat = 16*3
    
    var completionAction: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = frame
        
        self.addTapRecognizer(self, action: #selector(cancelButtonAction))
        self.gestureRecognizers?.first?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initSetUp()
        setUpAdditionalViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - SetUp methods
extension UICustomPresentViewController {
    private func initSetUp() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(navigationView)
        backgroundView.addSubview(contentView)
        navigationView.addSubview(cancelButton)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(doneButton)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        backgroundView.bringSubviewToFront(navigationView)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        
        initSetUpConstraints()
    }
    
    private func initSetUpConstraints() {
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundView.customHeightAnchorConstraint = backgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: standartInset*5)
        backgroundView.customHeightAnchorConstraint?.isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        navigationView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        navigationView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        navigationView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: doneButton.frame.height+standartInset/2).isActive = true
        
        cancelButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: standartInset).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor).isActive = true
        
        doneButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -standartInset).isActive = true
        
        contentView.customTopAnchorConstraint = contentView.topAnchor.constraint(equalTo: navigationView.bottomAnchor)
        contentView.customTopAnchorConstraint?.isActive = true
        contentView.customLeadingAnchorConstraint = contentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
        contentView.customLeadingAnchorConstraint?.isActive = true
        contentView.customTrailingAnchorConstraint = contentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        contentView.customTrailingAnchorConstraint?.isActive = true
        contentView.customBottomAnchorConstraint = contentView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        contentView.customBottomAnchorConstraint?.isActive = true
    }
}



// MARK: - View Show Hide Methods
extension UICustomPresentViewController {
    final func show(completion: ((Bool) -> Void)? = nil) {
        self.completionAction = completion
        moveDown(0.0)
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        guard let window = appDelegate.window else {
            return
        }
        if let fullFrame = window?.frame {
            self.frame = fullFrame
        }
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)
        moveUp(0.3)
    }
    
    func moveUp(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateShow(duration: duration)
        backgroundView.animateMove(y: 0, duration: duration, completion: completion)
    }
    
    func moveDown(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateFade(duration: duration)
        backgroundView.animateMove(y: self.frame.height, duration: duration, completion: completion)
    }
}



// MARK: - Actions
extension UICustomPresentViewController {
    @objc final func saveButtonAction() {
        if !saveAction() { return }
        completionAction?(true)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc final func cancelButtonAction() {
        if !cancelAction() { return }
        completionAction?(false)
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
}



// MARK: - Methods to override
extension UICustomPresentViewController {
    // override this methods to implement some actions to save / cancel / other views setup
    
    @objc func setUpAdditionalViews() {}
    
    @objc func saveAction() -> Bool { return true }
    
    @objc func cancelAction() -> Bool { return true }
}



// MARK: - Keyboard methods
extension UICustomPresentViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        //let y = self.frame.height * 0.1
        //mainView.animateMove(y: -y, duration: 0.3)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //mainView.animateMove(y: 0, duration: 0.3)
    }
}


//override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    guard let navView = touches.first?.view, navView == navigationView else { return }
//    navView.originPosition = navView.frame.origin
//    navView.touchBeganLocation = touches.first?.location(in: self)
//}
//
//override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//    guard let navView = touches.first?.view, navView == navigationView else { return }
//    let move = (navView.touchBeganLocation?.y ?? 0) - (touches.first?.location(in: self).y ?? 0)
//    navView.touchBeganLocation = touches.first?.location(in: self)
//    let const = (backgroundView.customHeightAnchorConstraint?.constant ?? 0) + move
//    if const > self.frame.height - topDragInset || const < bottomDragInset { return }
//    backgroundView.animateConstraint(backgroundView.customHeightAnchorConstraint, constant: const, duration: 0.0)
//}
//
//override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    guard let navView = touches.first?.view, navView == navigationView else { return }
//    let coef: CGFloat = (navView.originPosition?.y ?? 0)/navView.frame.origin.y
//    print(navView.frame.origin.y)
//    print(navigationView.frame.origin)
//    print(navView.originPosition?.y)
//    print("CoefE: \(coef)")
//}
//
//override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//    guard let navView = touches.first?.view, navView == navigationView else { return }
//    let coef: CGFloat = (navView.originPosition?.y ?? 0)/navView.frame.origin.y
//    print("CoefC: \(coef)")
//}
