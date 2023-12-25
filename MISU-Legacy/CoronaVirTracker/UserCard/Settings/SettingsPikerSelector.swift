//
//  SettingsPikerSelector.swift
//  CoronaVirTracker
//
//  Created by WH ak on 29.09.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SettingsPikerSelector: EditView {
    let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 20, color: .black, alignment: .center)
    let dateTimePiker: UIDatePicker = {
        let dtPiker = UIDatePicker()
        dtPiker.translatesAutoresizingMaskIntoConstraints = false
        dtPiker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            dtPiker.preferredDatePickerStyle = .wheels
        }
        dtPiker.maximumDate = Date()
        return dtPiker
    }()
    
    let customPickerView: UIPickerView = .createPickerView()
    
    enum PikerType {
        case age
        case sex
    }
    
    var pikerType: PikerType
    
    init(frame: CGRect, type: PikerType) {
        pikerType = type
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - Overrides
extension SettingsPikerSelector: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    
    override func setUpAdditionalViews() {
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        
        setUpTitleViews()
        
        switch pikerType {
        case .age:
            titleLabel.text = NSLocalizedString("Age", comment: "")
            setUpDateTimePiker()
            setUpAge()
        case .sex:
            titleLabel.text = NSLocalizedString("Sex", comment: "")
            setUpPiker()
            setUpSex()
        }
    }
    
    override func saveAction() -> Bool {
        let old = UCardSingleManager.shared.user
        
        switch pikerType {
        case .age:
            UCardSingleManager.shared.user.profile?.birthdayDate = dateTimePiker.date
        case .sex:
            UCardSingleManager.shared.user.profile?.gender = SexEnum.allCases[safe: customPickerView.selectedRow(inComponent: 0)]?.translate() ?? .none
        }
        
        prepareViewsBeforReqest(viewsToBlock: [saveButton, cancelButton], UIViewsToBlock: [customPickerView, dateTimePiker, self])
        saveButton.startActivity(style: .medium, color: .gray)
        UCardSingleManager.shared.saveToServer(old) { _ in
            self.enableViewsAfterReqest()
            self.saveButton.stopActivity()
            
            DispatchQueue.main.async {
                self.saveActionAfterRequest()
            }
        }
        
        return false
    }
}



// MARK: - PickerView Delegate & DataSource
extension SettingsPikerSelector: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SexEnum.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = String(SexEnum.allCases[row].localizeble)
        return label
    }
}



// MARK: - Additional views set up
extension SettingsPikerSelector {
    private func setUpAge() {
        if let bDay = UCardSingleManager.shared.user.profile?.birthdayDate?.getDateForRequest().toDate() {
            dateTimePiker.setDate(bDay, animated: true)
        }
    }
    
    private func setUpSex() {
        customPickerView.selectRow(1, inComponent: 0, animated: true)
        guard let sex = UCardSingleManager.shared.user.profile?.gender else { return }
        guard let row = SexEnum.allCases.firstIndex(where: {$0 == SexEnum.translate(from: sex)}) else { return }
        customPickerView.selectRow(row, inComponent: 0, animated: true)
        
    }
    
    private func setUpTitleViews() {
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    private func setUpDateTimePiker() {
        contentView.addSubview(dateTimePiker)
        
        dateTimePiker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        dateTimePiker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*2).isActive = true
        dateTimePiker.heightAnchor.constraint(equalToConstant: standartInset*10).isActive = true
        dateTimePiker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*2).isActive = true
        dateTimePiker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
    
    private func setUpPiker() {
        contentView.addSubview(customPickerView)
        
        customPickerView.delegate = self
        customPickerView.dataSource = self
        customPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        customPickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*2).isActive = true
        customPickerView.heightAnchor.constraint(equalToConstant: standartInset*8).isActive = true
        customPickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*2).isActive = true
        customPickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
}

