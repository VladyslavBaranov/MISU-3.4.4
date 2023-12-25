//
//  UIBarButtonItemCustomButtonExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/7/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    private struct OriginParameters {
        static var originMenu: [String:UIMenu] = [:]
        static var originParentVC: [String:UIViewController] = [:]
    }
    
    func getAddress() -> String? {
        return self.description.components(separatedBy: ";").first
    }
    
    var originMenu: UIMenu? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.originMenu[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.originMenu[address] = newValue
        }
    }
    
    var originParentVC: UIViewController? {
        get {
            guard let address = self.getAddress() else { return nil }
            return OriginParameters.originParentVC[address]
        }
        
        set(newValue) {
            guard let address = self.getAddress() else { return }
            OriginParameters.originParentVC[address] = newValue
        }
    }
    
    static func customButton(image: UIImage? = nil, style: UIBarButtonItem.Style = .plain, target: Any? = nil, action: Selector? = nil, menu: UIMenu? = nil, parentVC: UIViewController? = nil) -> UIBarButtonItem {
        
        let widthImg = (image?.size.width ?? 0)/(image?.size.height ?? 1)
        let img = image?.scaleTo(CGSize(width: 20*widthImg, height: 20))
        
        if #available(iOS 14.0, *) {
            let menuButton = UIBarButtonItem(image: img, style: style, target: target, action: action)
            menuButton.menu = menu
            return menuButton
        } else {
            let menuButton = UIBarButtonItem(image: img, style: style, target: UIBarButtonItem.self, action: #selector(showMenuController(_:)))
            menuButton.originParentVC = parentVC
            menuButton.originMenu = menu
            return menuButton
        }
    }
    
    typealias AlertHandler = @convention(block) (UIAction)->Void
    
    @objc static func showMenuController(_ target: UIBarButtonItem) {
        guard let menu = target.originMenu else { return }
        let menuController = UIAlertController(title: menu.title, message: nil, preferredStyle: .actionSheet)
        menu.children.forEach { child in
            menuController.addAction(UIAlertAction(title: child.title, style: .default, handler: { _ in
                guard let action = child as? UIAction, let block = action.value(forKey: "handler") else { return }
                let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
                handler(action)
            }))
        }
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = target.originParentVC?.view
        target.originParentVC?.present(menuController, animated: true)
    }
    
    static func menuButton(_ buttonType: UIButton.ButtonType = .system, target: Any?, action: Selector, tintColor: UIColor = .black, image: UIImage?, size: CGSize = CGSize(width: 24, height: 24), isRoundet: Bool = false) -> UIBarButtonItem {
        let button = UIButton(type: buttonType)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        let const = size.height*0.1
        button.imageEdgeInsets = .init(top: const, left: const, bottom: const, right: const)
        button.imageView?.contentMode = isRoundet ? .scaleAspectFill : .scaleAspectFit
        button.imageView?.cornerRadius = isRoundet ? (size.height/2)-const : 0
        button.tintColor = tintColor
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let img = image {
            let coef = img.size.width/img.size.height
            menuBarItem.customView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            menuBarItem.customView?.widthAnchor.constraint(equalToConstant: isRoundet ? size.height : size.height*coef).isActive = true
        } else {
            menuBarItem.customView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            menuBarItem.customView?.widthAnchor.constraint(greaterThanOrEqualToConstant: size.width).isActive = true
        }
        
        return menuBarItem
    }
}
