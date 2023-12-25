//
//  StringExt.swift
//  WishHook
//
//  Created by KNimtur on 9/25/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}

extension String {
    func convertFromHTML() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        return attributedString
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func getSize(fontSize: CGFloat? = nil) -> CGSize {
        let label = UILabel()
       
        if let size = fontSize {
            label.font = UIFont.systemFont(ofSize: size)
        }
        
        label.text = self
        label.sizeToFit()
        return label.frame.size
    }
    
    mutating func clearEmptyEnters() {
        if self.last == "\n" {
            self.removeLast()
            clearEmptyEnters()
        }
    }
    
    mutating func clearEmptyEntersAndSpaces() {
        if self.last == " " || self.last == "\n" {
            self.removeLast()
            clearEmptyEntersAndSpaces()
            return
        }
        
        if self.first == " " || self.first == "\n" {
            self.removeFirst()
            clearEmptyEntersAndSpaces()
            return
        }
    }
    
    func toDateOnly(withFormat format: String = "yyyy-MM-dd") -> Date? {
        guard let date = toDate(withFormat: format) else { return nil }
        guard let dateOnly = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) else {
            return nil
        }
        return dateOnly
    }
    
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", ch: Bool = false, local: Bool = true, isGMT: Bool = false) -> Date? {
        let formatter4 = DateFormatter()
        formatter4.dateFormat = format
        //formatter4.timeZone = ch ? TimeZone.init(secondsFromGMT: 2) : TimeZone(abbreviation: "GMT")

        //self.addingTimeInterval(targetOffset - localOffeset)
        if local {
            formatter4.locale = Locale.current
            formatter4.timeZone = TimeZone.current
        }
        if isGMT {
            formatter4.timeZone = TimeZone(abbreviation: "GMT")
        }
        if let date = formatter4.date(from: self) {
            return date
        }
        formatter4.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        if let date = formatter4.date(from: self) {
            return date
        }
        formatter4.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter4.date(from: self) {
            return date
        }
        formatter4.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter4.date(from: self) {
            return date
        }
        formatter4.dateFormat = "yyyy-MM-dd"
        if let date = formatter4.date(from: self) {
            return date
        }
        return nil
    }
    
    func removeHTTPS() -> String {
        return self.replacingOccurrences(of: "https://", with: "")
    }
}
