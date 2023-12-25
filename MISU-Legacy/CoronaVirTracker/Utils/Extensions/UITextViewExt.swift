//
//  UITextViewExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 04.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UITextView {
    private struct ParametersStruct {
        static var placeholder: [String:String] = [:]
    }
    
    var placeholder: String? {
        get {
            guard let address = self.getAddress() else { return nil }
            return ParametersStruct.placeholder[address]
        }
        
        set(newValue) {
            self.text = newValue
            self.textColor = .lightGray
            guard let address = self.getAddress() else { return }
            ParametersStruct.placeholder[address] = newValue
        }
    }
    
    func isPlaceholder() {
        if self.placeholder != nil, self.text == self.placeholder {
            self.text = ""
            self.textColor = self.originTextColor
        }
    }
    
    func placeholderIfNeeded() {
        guard let txt = self.text, txt.isEmpty else { return }
        
        let pl = self.placeholder
        self.placeholder = pl
    }
}



extension UITextView {
    var maxNumberOfLines: Int {
        get {
            return 5
        }
    }
    
    func numberOfLines() -> Int {
        let oneLineHeight = "Nice".getSize(fontSize: self.font?.pointSize).height
        if let oneLine = self.font?.lineHeight {
            return Int(self.contentSize.height/oneLine)
        }
        return Int(self.contentSize.height/oneLineHeight)
    }
}

