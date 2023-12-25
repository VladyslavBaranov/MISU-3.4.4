//
//  UIPickerViewCustomCreateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 09.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIPickerView {
    static func createPickerView() -> UIPickerView {
        let pk = UIPickerView()
        pk.translatesAutoresizingMaskIntoConstraints = false
        return pk
    }
}
