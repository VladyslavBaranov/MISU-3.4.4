//
//  UIColorExt.swift
//  WishHook
//
//  Created by KNimtur on 10/2/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    struct appDefault {
        static var red: UIColor { return UIColor(hexString: "#FF2D55") }
        static var redNew: UIColor { return UIColor(hexString: "#DD284A") }
        static var redNika: UIColor { return UIColor(hexString: "#F53D7A") }
        
        static var blue: UIColor { return UIColor(hexString: "#4390DE") }
        static var bluePrimary: UIColor { return UIColor(hexString: "#2C98F0") }
        static var blueLight: UIColor {return UIColor(hexString: "#5E9BFF")}
        static var blueUltraLight: UIColor {return UIColor(hexString: "#AFC6DE")}
        static var blueNika: UIColor {return UIColor(hexString: "#0189FF")}
        
        static var green: UIColor { return UIColor(hexString: "#54BDB0") }
        static var yellow: UIColor {return UIColor(hexString: "#FFD60A")}
        
        static var black: UIColor { return UIColor(hexString: "#1D1D1D") }
        static var blackPrimary: UIColor { return UIColor(hexString: "#494949") }
        static var blackKoliya: UIColor { return UIColor(hexString: "#171926") }
        static var lightGrey: UIColor { return UIColor(hexString: "#F8F8F8") }
        static var white: UIColor { return UIColor(hexString: "#FFFFFF") }
    }
    
    convenience init(hexString hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
