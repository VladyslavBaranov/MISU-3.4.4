//
//  PinViewTextFieldDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 30.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - UITextFieldDelegate
extension UIPinUnderLinedTextFieldView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let prev = textField.superview?.viewWithTag(textField.tag-1) as? UITextField {
            if (prev.text?.isEmpty ?? true), textField.text?.isEmpty ?? true {
                checkEmpty(textField)
                prev.becomeFirstResponder()
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let underTF = textField as? UIUnderLinedTextField {
            underTF.setSelected()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return cleareSumbols(textField)
        } else if string.count > 1 {
            textField.endEditing(true)
            insertionText(textField, string: string)
            return false
        }
        
        if (textField.text?.count ?? 0) >= 1, !string.isEmpty {
            goToNextTextField(textField, string: string)
            return false
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("textFieldDidChangeSelection")
        /*if !(textField.text?.isEmpty ?? true) {
            goToNext(textField)
        }*/
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let underTF = textField as? UIUnderLinedTextField, underTF.text?.isEmpty ?? true {
            underTF.setUnSelected()
        }
    }
}


extension UIPinUnderLinedTextFieldView: DeleteBackwardDelegate {
    func textFieldDidDeleteBackward(textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            (textField.superview?.viewWithTag(textField.tag-1) as? UITextField)?.text = ""
            goToPrev(textField)
        }
    }
}



// MARK: - UITextFieldDelegate custom methods
extension UIPinUnderLinedTextFieldView {
    private func insertionText(_ textField: UITextField, string: String) {
        guard let one = string.first else { return }
        textField.text = String(one)
        (textField as? UIUnderLinedTextField)?.setSelected()
        
        if let next = textField.superview?.viewWithTag(textField.tag+1) as? UITextField {
            insertionText(next, string: String(string.dropFirst()))
        }
    }
    
    private func checkEmpty(_ textField: UITextField) {
        if let txtF = textField as? UIUnderLinedTextField {
            if txtF.text?.isEmpty ?? true {
                txtF.setUnSelected()
            }
        }
    }
    
    private func goToPrev(_ textField: UITextField) {
        if let prev = textField.superview?.viewWithTag(textField.tag-1) as? UITextField {
            prev.becomeFirstResponder()
        }
    }
    
    private func goToNext(_ textField: UITextField) {
        if let next = textField.superview?.viewWithTag(textField.tag+1) as? UITextField {
            next.becomeFirstResponder()
        } else if !(textField.text?.isEmpty ?? true) {
            textField.endEditing(true)
            pinDelegate?.pinTextFieldDidEndFilling?(text: self.text)
        }
    }
    
    private func cleareSumbols(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty ?? true {
            if let prev = textField.superview?.viewWithTag(textField.tag-1) as? UITextField {
                prev.becomeFirstResponder()
            }
            return true
        }
        return true
    }
    
    private func goToNextTextField(_ textField: UITextField, string: String) {
        if let next = textField.superview?.viewWithTag(textField.tag+1) as? UITextField {
            next.becomeFirstResponder()
            next.text = string
            
            if next.tag == underLineTextFields.last?.tag {
                next.endEditing(true)
                pinDelegate?.pinTextFieldDidEndFilling?(text: self.text)
            }
        } else {
            textField.endEditing(true)
        }
    }
}
