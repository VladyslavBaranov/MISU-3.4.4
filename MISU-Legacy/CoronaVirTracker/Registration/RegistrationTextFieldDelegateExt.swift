//
//  RegistrationTextFieldDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 27.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension RegistrationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true || textField.text == "" {
            authModel.clearUserDef()
        }
    }
}
