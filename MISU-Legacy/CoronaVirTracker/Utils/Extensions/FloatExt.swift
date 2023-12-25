//
//  FloatExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/28/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension Float {
    func getIntPart() -> Int {
        return Int(self)
    }
    
    func getDecPartFirstNum() -> Int {
        return Int(roundf(self.truncatingRemainder(dividingBy: 1)*10))
    }
    
    static func buildFloat(integer: Int, dec: Int) -> Float? {
        return Float("\(integer).\(dec)")
    }
}

extension Int {
    func getHoursAndMinuts() -> String {
        let h = self/60
        let m = self - h*60
        return "\(h)" + NSLocalizedString("h", comment: "") + " \(m)" + NSLocalizedString("m", comment: "")
    }
    
    func getHoursAndMinuts(font: UIFont = .systemFont(ofSize: 12, weight: .light)) -> NSAttributedString {
        let h = self/60
        let m = self - h*60
        let hText = NSLocalizedString("h", comment: "")
        let mText = NSLocalizedString("m", comment: "")
        let allText = "\(h)" + hText + " \(m)" + mText
        
        let attrStr = NSMutableAttributedString(string: allText)
        attrStr.setAttributes([.font: font], range: (allText as NSString).range(of: hText))
        attrStr.setAttributes([.font: font], range: (allText as NSString).range(of: mText))
        return attrStr
    }
}
