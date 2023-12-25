//
//  SexEditView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 11.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class SexEditView: BaseEditView {
    let contentStack: UIStackView = .createCustom(axis: .vertical)
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Sex", comment: ""), fontSize: 20, alignment: .center)
    let pickerView: UIPickerView = .createPickerView()
    
    var selectedSex: SexEnum {
        get {
            return SexEnum(forScrollId: pickerView.selectedRow(inComponent: 0))
        }
        set {
            pickerView.selectRow(newValue.idForScroll, inComponent: 0, animated: true)
        }
    }
    
    override func setUp() {
        super.setUp()
        
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(pickerView)
        contentStack.customCentrConstraints(on: contentView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}

extension SexEditView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SexEnum.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = String(SexEnum(forScrollId: row).localizeble)
        return label
    }
}
