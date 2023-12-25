//
//  StatisticEditTextFieldDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 24.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension StatisticEditView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let underTF = textField as? UIUnderLinedTextField {
            underTF.setSelected()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let underTF = textField as? UIUnderLinedTextField {
            underTF.setUnSelected()
        }
    }
}
