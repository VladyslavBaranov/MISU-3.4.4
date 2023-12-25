//
//  UIViewExt.swift
//  WishHook
//
//  Created by KNimtur on 9/11/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){

        self.init()

        let path = CGMutablePath()

        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
             path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }

        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }

        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }

        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        path.closeSubpath()
        cgPath = path
    }
}



// MARK: - Touches, Drugs, derorators
extension UIView {
    static func createCustom(bgColor: UIColor = .clear, cornerRadius cr_: CGFloat? = nil) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = bgColor
        if let cr = cr_ { v.cornerRadius = cr }
        return v
    }
    
    var standart16Inset: CGFloat {
        return 16
    }
    
    var standartInset: CGFloat {
        return standart16Inset
    }
    
    var standart24Inset: CGFloat {
        return 24
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    enum DragDirection {
        case horizontal
        case vertical
    }
    
    private struct TouchBeganStruct {
        static var location: [String:CGPoint] = [:]
        static var isMovedOut: [String:Bool] = [:]
        static var isTouching: [String:Bool] = [:]
        static var dragDirection: [String:DragDirection] = [:]
    }
    
    var dragDirection: DragDirection? {
        get {
            guard let address = self.getAddress() else { return nil }
            return TouchBeganStruct.dragDirection[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            TouchBeganStruct.dragDirection[address] = newValue
        }
    }
    
    var isTouching: Bool? {
        get {
            guard let address = self.getAddress() else { return nil }
            return TouchBeganStruct.isTouching[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            TouchBeganStruct.isTouching[address] = newValue
        }
    }
    
    var touchBeganLocation: CGPoint? {
        get {
            guard let address = self.getAddress() else { return nil }
            return TouchBeganStruct.location[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            TouchBeganStruct.location[address] = newValue
        }
    }
    
    var isTouchMovedOut: Bool {
        get {
            guard let address = self.getAddress(), let isMoved = TouchBeganStruct.isMovedOut[address] else { return false }
            return isMoved
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            TouchBeganStruct.isMovedOut[address] = newValue
        }
    }
    
    func isTouchMoveOut(touch: UITouch) -> Bool {
        let tLocation = touch.location(in: self)
        
        if tLocation.x < 0 || tLocation.y < 0 ||
           tLocation.x > self.frame.size.width ||
           tLocation.y > self.frame.size.height {
            return true
        }
        
        
        return false
    }
    
    func setCustomCornerRadius() {
        self.cornerRadius = 10
    }
    
    func getAddress() -> String? {
        return self.description.components(separatedBy: ";").first
    }
    
    func addShadow(radius: CGFloat, offset: CGSize, opacity: Float, color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func addCustomShadow(shadowOffset: CGSize = CGSize(width: 0, height: 2), opacity: Float = 0.5, radius: CGFloat = 2) {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.cornerRadius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func addPseudoShadow(shadowOffset: CGSize = CGSize(width: 0, height: 2), opacity: Float = 0.5, radius: CGFloat = 2) {
        let shadowView: UIView = .createCustom()
        self.addSubview(shadowView)
        shadowView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        shadowView.addCustomShadow(shadowOffset: shadowOffset, opacity: opacity, radius: radius)
    }
    
    func addCustomBorder(radius: CGFloat = 1, color: UIColor = UIColor.black.withAlphaComponent(0.1)) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = radius
        self.layer.masksToBounds = false
    }
    
    func makeShadowAndRounded() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 2
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        //self.clipsToBounds = true
        
        //self.layoutIfNeeded()
    }
    
    func setRoundedParticly(corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: CGFloat = 10) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        self.clipsToBounds = true
    }
    
    func setRounded(byCorners: UIRectCorner, cornerRadii: CGSize = .init(width: 18.0, height: 0.0)) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: byCorners,
                                    cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        clipsToBounds = false
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        
        layer.mask = shape
        
        layer.shadowPath = maskPath.cgPath
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
    }
    
    func addBorder(radius: CGFloat, color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = radius
        self.layer.masksToBounds = false
    }
    
    func removeShadow() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOpacity = 0.0
        self.layer.shadowRadius = 0
    }
    
    func addTapRecognizer(_ target: Any, action: Selector?) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    func addTargetToFirstRecognizer(_ target: Any, action: Selector) {
        guard let recognizer = self.gestureRecognizers?.first else {
            print("no recognizer \(String(describing: self.gestureRecognizers))")
            return
        }
        
        recognizer.addTarget(target, action: action)
    }
    
    func addEndEditTapRecognizer(cancelsTouchesInView: Bool = false) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToEndEdit))
        tap.cancelsTouchesInView = cancelsTouchesInView
        self.addGestureRecognizer(tap)
    }
    
    @objc private func tapToEndEdit() {
        endEditing(true)
    }
    
    func addProgressView(unit: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) -> UIView {
        let progressView: UIView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height))
        
        progressView.cornerRadius = height/2
        
        progressView.backgroundColor = color
        
        self.addSubview(progressView)
        
        progressView.animateScaleFrame(
            x: self.frame.width * unit - width,
            y: 0,
            duration: 1.0)
        
        return progressView
    }
}



// MARK: - Navigation & Controller
extension UIView {
    func firstSuperviewOfType<T>() -> T? {
        guard let sp = self.superview else { return nil }
        if let vw = sp as? T {
            return vw
        }
        return sp.firstSuperviewOfType()
    }
    
    func controller() -> UIViewController? {
        if let nextViewControllerResponder = next as? UIViewController {
            return nextViewControllerResponder
        } else if let nextViewResponder = next as? UIView {
            return nextViewResponder.controller()
        } else {
            return nil
        }
    }
    
    func navigationController() -> UINavigationController? {
        if let controller = controller() {
            return controller.navigationController
        } else {
            return nil
        }
    }
    
    func isSubViewsFirstResponder(view: UIView) -> Bool {
        var isKeyboard = false
        view.subviews.forEach { subview in
            isKeyboard = subview.isSubViewsFirstResponder(view: subview) || isKeyboard
            if subview.isFirstResponder {
                isKeyboard = true
            }
        }
        return isKeyboard
    }
    
    func hasSubView(_ view: UIView) -> Bool {
        var isSubview = false
        self.subviews.forEach { subview in
            isSubview = subview.hasSubView(view)
            if subview == view {
                isSubview = true
            }
        }
        return isSubview
    }
}



// MARK: - Custom constrains
extension UIView {
    private struct CustomConstraints {
        static var topAnchor: [String:NSLayoutConstraint] = [:]
        static var leadingAnchor: [String:NSLayoutConstraint] = [:]
        static var leftAnchor: [String:NSLayoutConstraint] = [:]
        static var trailingAnchor: [String:NSLayoutConstraint] = [:]
        static var rightAnchor: [String:NSLayoutConstraint] = [:]
        static var bottomAnchor: [String:NSLayoutConstraint] = [:]
        
        static var widthAnchor: [String:NSLayoutConstraint] = [:]
        static var heightAnchor: [String:NSLayoutConstraint] = [:]
        static var centerXAnchor: [String:NSLayoutConstraint] = [:]
        static var centerYAnchor: [String:NSLayoutConstraint] = [:]
    }
    
    var customTopAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.topAnchor, firstAttribute: .top)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.topAnchor)
        }
    }
    
    var customLeadingAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.leadingAnchor, firstAttribute: .leading)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.leadingAnchor)
        }
    }
    
    var customLeftAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.leftAnchor, firstAttribute: .left)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.leftAnchor)
        }
    }
    
    var customTrailingAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.trailingAnchor, firstAttribute: .trailing)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.trailingAnchor)
        }
    }
    
    var customRightAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.rightAnchor, firstAttribute: .right)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.rightAnchor)
        }
    }
    
    var customBottomAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.bottomAnchor, firstAttribute: .bottom)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.bottomAnchor)
        }
    }
    
    var customWidthAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.widthAnchor, firstAttribute: .width)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.widthAnchor)
        }
    }
    
    var customHeightAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.heightAnchor, firstAttribute: .height)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.heightAnchor)
        }
    }
    
    var customCenterXAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.centerXAnchor, firstAttribute: .centerX)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.centerXAnchor)
        }
    }
    
    var customCenterYAnchorConstraint: NSLayoutConstraint? {
        get {
            return getConstraint(from: &CustomConstraints.centerYAnchor, firstAttribute: .centerY)
        }
        
        set(newValue) {
            setConstraint(newValue, to: &CustomConstraints.centerYAnchor)
        }
    }
    
    fileprivate func setConstraint(_ value: NSLayoutConstraint?, to: inout [String:NSLayoutConstraint]) {
        guard let address = self.getAddress() else { return }
        to[address] = value
    }
    
    fileprivate func getConstraint(from: inout [String:NSLayoutConstraint], firstAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        guard let address = self.getAddress(), let constr = from[address] else {
            var constrain: NSLayoutConstraint? = nil
            self.constraints.forEach { constr in
                if constr.firstAttribute == firstAttribute { constrain = constr }
            }
            return constrain
        }
        return constr
    }
    
    func clearCustomConstraints() {
        [customCenterYAnchorConstraint, customCenterXAnchorConstraint, customLeadingAnchorConstraint, customTopAnchorConstraint, customTrailingAnchorConstraint, customBottomAnchorConstraint].forEach { _constr in
            guard let c = _constr else { return }
            c.isActive = false
            removeConstraint(c)
        }
        customCenterYAnchorConstraint = nil
        customCenterXAnchorConstraint = nil
        customLeadingAnchorConstraint = nil
        customTopAnchorConstraint = nil
        customTrailingAnchorConstraint = nil
        customBottomAnchorConstraint = nil
    }
    
    func customConstraints(alignment: NSRectAlignment = .none, on view: UIView? = nil, inset: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)) {
        guard let view = view ?? superview else { return }
        
        if alignment == .none || alignment == .leading || alignment == .trailing {
            customCenterYAnchorConstraint = centerYAnchor.constraint(equalTo: view.centerYAnchor)
            customCenterYAnchorConstraint?.isActive = true
        }
        
        if alignment == .none || alignment == .top || alignment == .bottom {
            customCenterXAnchorConstraint = centerXAnchor.constraint(equalTo: view.centerXAnchor)
            customCenterXAnchorConstraint?.isActive = true
        }
        
        if alignment == .leading || alignment == .topLeading || alignment == .bottomLeading {
            customLeadingAnchorConstraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset.left)
        } else {
            customLeadingAnchorConstraint = leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: inset.left)
        }
        
        if alignment == .top || alignment == .topLeading || alignment == .topTrailing {
            customTopAnchorConstraint = topAnchor.constraint(equalTo: view.topAnchor, constant: inset.top)
        } else {
            customTopAnchorConstraint = topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: inset.top)
        }
        
        if alignment == .trailing || alignment == .topTrailing || alignment == .bottomTrailing {
            customTrailingAnchorConstraint = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset.right)
        } else {
            customTrailingAnchorConstraint = trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -inset.right)
        }
        
        if alignment == .bottom || alignment == .bottomTrailing || alignment == .bottomLeading {
            customBottomAnchorConstraint = bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -inset.bottom)
        } else {
            customBottomAnchorConstraint = bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -inset.bottom)
        }
        
        [customLeadingAnchorConstraint, customTopAnchorConstraint, customTrailingAnchorConstraint, customBottomAnchorConstraint].forEach({ $0?.isActive = true })
    }
    
    func customCentrConstraints(on view: UIView? = nil, inset: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)) {
        guard let view = view ?? superview else { return }
        customCenterYAnchorConstraint = centerYAnchor.constraint(equalTo: view.centerYAnchor)
        customCenterXAnchorConstraint = centerXAnchor.constraint(equalTo: view.centerXAnchor)
        customLeadingAnchorConstraint = leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: inset.left)
        customTopAnchorConstraint = topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: inset.top)
        customTrailingAnchorConstraint = trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -inset.right)
        customBottomAnchorConstraint = bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -inset.bottom)
        [customCenterYAnchorConstraint, customCenterXAnchorConstraint, customLeadingAnchorConstraint, customTopAnchorConstraint, customTrailingAnchorConstraint, customBottomAnchorConstraint].forEach({ $0?.isActive = true })
        
    }
    
    func fixedEdgesConstraints(on view: UIView? = nil, inset: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)) {
        guard let view = view ?? superview else { return }
        customLeadingAnchorConstraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset.left)
        customTopAnchorConstraint = topAnchor.constraint(equalTo: view.topAnchor, constant: inset.top)
        customTrailingAnchorConstraint = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset.right)
        customBottomAnchorConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset.bottom)
        [customLeadingAnchorConstraint, customTopAnchorConstraint, customTrailingAnchorConstraint, customBottomAnchorConstraint].forEach({ $0?.isActive = true })
    }
}



// MARK: - Origin
extension UIView {
    private struct OriginParameters {
        static var color: [String:UIColor] = [:]
        static var tempColor: [String:UIColor] = [:]
        static var size: [String:CGSize] = [:]
        static var frame: [String:CGRect] = [:]
        static var position: [String:CGPoint] = [:]
        static var fontSize: [String:CGFloat] = [:]
        static var textColor: [String:UIColor] = [:]
        static var text: [String:String] = [:]
        static var image: [String:UIImage] = [:]
        static var activityView: [String:UIActivityIndicatorView] = [:]
        static var budgetView: [String:UILabel] = [:]
        static var scrollViewSize: [String:CGSize] = [:]
        static var scrollViewOffset: [String:CGPoint] = [:]
        static var shadowLayer: [String:CAShapeLayer] = [:]
        static var contentView: [String:UIView] = [:]
    }
    
    var originContentView: UIView? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.contentView[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.contentView[address] = newValue
        }
    }
    
    var originShadowLayer: CAShapeLayer? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.shadowLayer[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.shadowLayer[address] = newValue
        }
    }
    
    var originScrollViewOffset: CGPoint? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.scrollViewOffset[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.scrollViewOffset[address] = newValue
        }
    }
    
    var originScrollViewSize: CGSize? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.scrollViewSize[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.scrollViewSize[address] = newValue
        }
    }
    
    var budgetValueCustom: String? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.budgetView[address]?.text
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            if newValue == nil {
                OriginParameters.budgetView[address]?.removeFromSuperview()
                OriginParameters.budgetView[address] = nil
            } else if let budgetView = OriginParameters.budgetView[address] {
                budgetView.text = newValue
            } else {
                let x = self.frame.size.width*0.6
                let y = self.frame.size.height*0.2
                let label = UILabel(frame: CGRect(x: x, y: -y, width: 16, height: 16))
                label.layer.borderColor = UIColor.clear.cgColor
                label.layer.borderWidth = 2
                label.layer.cornerRadius = label.bounds.size.height / 2
                label.textAlignment = .center
                label.layer.masksToBounds = true
                label.font = UIFont.systemFont(ofSize: 12)
                label.textColor = .white
                label.backgroundColor = .red
                label.text = newValue
                self.addSubview(label)
                OriginParameters.budgetView[address] = label
            }
        }
    }
    
    var originActivityView: UIActivityIndicatorView? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.activityView[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.activityView[address] = newValue
        }
    }
    
    var originText: String? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.text[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.text[address] = newValue
        }
    }
    
    var originImage: UIImage? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.image[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.image[address] = newValue
        }
    }
    
    var originPosition: CGPoint? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.position[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.position[address] = newValue
        }
    }
    
    var originSize: CGSize? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.size[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.size[address] = newValue
        }
    }
    
    var originFrame: CGRect? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.frame[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.frame[address] = newValue
        }
    }
    
    var originColor: UIColor? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.color[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.color[address] = newValue
        }
    }
    
    var originFontSize: CGFloat? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.fontSize[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.fontSize[address] = newValue
        }
    }
    
    var tempColor: UIColor? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.tempColor[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.tempColor[address] = newValue
        }
    }
    
    var originTextColor: UIColor? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.textColor[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.textColor[address] = newValue
        }
    }
}
