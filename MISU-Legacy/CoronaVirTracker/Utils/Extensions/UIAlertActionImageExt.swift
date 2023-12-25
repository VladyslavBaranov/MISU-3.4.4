//
//  UIAlertActionImageExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIAlertAction {
    var customImage: UIImage? {
        get {
            return self.value(forKey: "image") as? UIImage
        }
        set {
            self.setValue(newValue, forKey: "image")
        }
    }
    
    var customTitleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        }
        set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
