//
//  VaccinesEditView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class VaccinesEditView: BaseEditView {
    let contentStack: UIStackView = .createCustom(axis: .vertical)
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Select vaccine and date of vaccination", comment: ""), fontSize: 20, alignment: .center, numberOfLines: 3)
    let pickerView: UIPickerView = .createPickerView()
    let dateTimePiker: UIDatePicker = {
        let dtPiker = UIDatePicker()
        dtPiker.translatesAutoresizingMaskIntoConstraints = false
        dtPiker.datePickerMode = .date 
        if #available(iOS 13.4, *) {
            dtPiker.preferredDatePickerStyle = .compact
        }
        dtPiker.maximumDate = Date()
        return dtPiker
    }()
    
    var selectedVaccine: VaccineModel? {
        get {
            guard let vac = ListDHUSingleManager.shared.vaccinesStruct[pickerView.selectedRow(inComponent: 0)],
                  vac.id != nil else { return nil }
            let date = dateTimePiker.date
            return .init(vacConst: vac, date: date)
        }
        set {
            pickerView.selectRow((newValue?.id ?? -1)+1, inComponent: 0, animated: true)
            dateTimePiker.setDate(newValue?.date ?? Date(), animated: true)
        }
    }
    
    override func setUp() {
        super.setUp()
        delegate = self
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(pickerView)
        contentStack.addArrangedSubview(dateTimePiker)
        contentStack.customCentrConstraints(on: contentView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}

extension VaccinesEditView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ListDHUSingleManager.shared.vaccinesStruct.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = String(ListDHUSingleManager.shared.vaccinesStruct[row]?.value ?? "-")
        return label
    }
}

extension VaccinesEditView: BaseEditViewDelegate {
    func willShow(editView: BaseEditView) {
        guard ListDHUSingleManager.shared.vaccinesList.count <= 0 else { return }
        
        ListDHUSingleManager.shared.getVaccines {
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }
}
