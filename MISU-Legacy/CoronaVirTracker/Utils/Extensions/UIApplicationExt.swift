//
//  UIApplicationExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/16/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIApplication {
    var customKeyWindow: UIWindow? {
        get {
            return UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
        }
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.customKeyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
