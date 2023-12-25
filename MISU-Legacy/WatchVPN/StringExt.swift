//
//  StringExt.swift
//  WishHook
//
//  Created by KNimtur on 9/25/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import UIKit

enum PhoneValidationCountries: CaseIterable {
    case ua
    case kz
    case all
    
    func check(_ phone: String) -> PhoneValidationCountries? {
        switch self {
        case .ua:
            if phone.isValidUAPhone() { return .ua }
        case .kz:
            if phone.isValidKZPhone() { return .kz }
        case .all:
            var allWA = PhoneValidationCountries.allCases
            allWA.removeAll(where: { $0 == .all })
            var result: PhoneValidationCountries? = nil
            allWA.forEach { country in
                result = (country.check(phone) != nil) ? country.check(phone) : result
            }
            return result
        }
        return nil
    }
    
    func makeFull(_ phone: String) -> String {
        var ph = phone
        switch self {
        case .ua:
            ph.makeFullUAPhone()
        case .kz:
            ph.makeFullKZPhone()
        case .all:
            break
        }
        return ph
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPhone(_ countries: [PhoneValidationCountries] = [.all]) -> PhoneValidationCountries? {
        if countries.firstIndex(of: .all) != nil {
            return PhoneValidationCountries.all.check(self)
        } else {
            var result: PhoneValidationCountries? = nil
            countries.forEach { country in
                result = country.check(self)
            }
            return result
        }
    }
    
    func isValidUAPhone() -> Bool {
        let phoneRegEx = "((\\+){0,1})+((38){0,1})+0{1}+[0-9]{9}"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self)
    }
    
    func isValidKZPhone() -> Bool {
        let phoneRegEx = "((\\+){0,1})+((7){0,1})+[6-7]{1}+[0-9]{9}"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self)
    }
    
    mutating func makeFullUAPhone() {
        if self.count == 13 { return }
        if self.count == 12 { self = "+"+self }
        if self.count == 10 { self = "+38"+self }
    }
    
    mutating func makeFullKZPhone() {
        if self.count == 12 { return }
        if self.count == 11 { self = "+"+self }
        if self.count == 10 { self = "+7"+self }
    }
    
    func isValidPass() -> Bool {
        if self.isEmpty {
            return true
        } else if self.count < 8 {
            return false
        }
        return true
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
    
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", ch: Bool = false) -> Date? {
        let formatter4 = DateFormatter()
        formatter4.dateFormat = format
        formatter4.timeZone = ch ? TimeZone.init(secondsFromGMT: 2) : TimeZone(abbreviation: "GMT")
        //formatter4.timeZone = TimeZone.current
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
