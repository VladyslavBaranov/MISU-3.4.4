//
//  UIViewControllerExt.swift
//  WishHook
//
//  Created by KNimtur on 10/9/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func popAllChildren() {
        print(self.children)
    }
    
    var topBarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var navigationBarHeight: CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 0.0
    }
}
