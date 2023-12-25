//
//  GeneralInfoDoctorPikerControllerExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension GeneralInfoDoctorEditView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ListDHUSingleManager.shared.doctorPosts.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var lab = UILabel()
        if let vw = view as? UILabel {
            lab = vw
        }
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textAlignment = .center
        lab.text = ListDHUSingleManager.shared.doctorPosts[safe: row]?.name ?? "-"
        return lab
    }
}
