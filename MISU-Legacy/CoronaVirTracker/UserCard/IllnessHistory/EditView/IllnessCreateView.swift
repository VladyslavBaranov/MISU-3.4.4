//
//  IllnessCreateView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 16.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class IllnessCreateView: EditView {
    //let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 20, color: .black, alignment: .center)
    
    let illnessSelectButton: UIButton = .createCustom(title: NSLocalizedString("Select Illness", comment: ""), color: .white, fontSize: 16, textColor: .black, shadow: false)
    let confirmationPickerView: UIPickerView = .createPickerView()
    let statePickerView: UIPickerView = .createPickerView()
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
    
    var illnessId: Int = -1
    var illnessModel: IllnessModel? {
        get {
            guard let txt = illnessSelectButton.titleLabel?.text, txt != NSLocalizedString("Select Illness", comment: "") else { return nil }
            let conf = IllnessConfirmedEnum.allCases[safe: confirmationPickerView.selectedRow(inComponent: 0)] ?? .notConfirmed
            let state = IllnessStateEnum.allCases[safe: statePickerView.selectedRow(inComponent: 0)] ?? .ill
            
            return .init(id: illnessId,name: txt, confirmed: conf, state: state, date: dateTimePiker.date)
        }
        
        set {
            guard let ill = newValue else { return }
            illnessId = ill.id
            illnessSelectButton.setTitle(ill.name, for: .normal)
            if let confId = ill.confirmed?.rawValue {
                confirmationPickerView.selectRow(confId, inComponent: 0, animated: false)
            }
            if let stateId = ill.state?.rawValue {
                statePickerView.selectRow(stateId, inComponent: 0, animated: false)
            }
            dateTimePiker.setDate(ill.date ?? Date(), animated: false)
            saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        }
    }
    
    init(frame: CGRect, illnessModel ill: IllnessModel) {
        super.init(frame: frame)
        
        illnessModel = ill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - Actions
extension IllnessCreateView {
    @objc func illnessSelectAction() {
        let addSIView = SelectIllnessEditView(frame: self.frame)
        addSIView.show { _ in
            if !addSIView.selectedIll.isEmpty {
                self.illnessSelectButton.setTitle(addSIView.selectedIll, for: .normal)
            }
        }
    }
}



// MARK: - Overrides
extension IllnessCreateView {
    override func setUpAdditionalViews() {
        saveButton.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        
        setUpTitleViews()
        setUpTextView()
        setUpDateTimePiker()
        
        confirmationPickerView.selectRow(IllnessConfirmedEnum.allCases.count/2, inComponent: 0, animated: false)
        statePickerView.selectRow(IllnessStateEnum.allCases.count/2, inComponent: 0, animated: false)
    }
    
    override func saveAction() -> Bool {
        return true
    }
}



// MARK: - PickerView Delegate, DataSource
extension IllnessCreateView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case confirmationPickerView:
            return IllnessConfirmedEnum.allCases.count
        case statePickerView:
            return IllnessStateEnum.allCases.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var lab = UILabel()
        if let vw = view as? UILabel {
            lab = vw
        }
        
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textAlignment = .center
        
        switch pickerView {
        case confirmationPickerView:
            lab.text = IllnessConfirmedEnum.allCases[safe: row]?.localized ?? "-"
            return lab
        case statePickerView:
            lab.textColor = IllnessStateEnum.allCases[safe: row]?.color ?? .black
            lab.text = IllnessStateEnum.allCases[safe: row]?.localized ?? "-"
            return lab
        default:
            return UIView()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return standartInset*2.5
    }
}



// MARK: - Additional views set up
extension IllnessCreateView {
    private func setUpTitleViews() {
        //contentView.addSubview(titleLabel)
        
        //titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        //titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    private func setUpTextView() {
        contentView.addSubview(illnessSelectButton)
        contentView.addSubview(confirmationPickerView)
        contentView.addSubview(statePickerView)
        
        illnessSelectButton.addBorder(radius: 1, color: .lightGray)
        illnessSelectButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        illnessSelectButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        illnessSelectButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        illnessSelectButton.addTarget(self, action: #selector(illnessSelectAction), for: .touchUpInside)
        
        confirmationPickerView.delegate = self
        confirmationPickerView.dataSource = self
        confirmationPickerView.topAnchor.constraint(equalTo: illnessSelectButton.bottomAnchor).isActive = true
        confirmationPickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset/2).isActive = true
        confirmationPickerView.heightAnchor.constraint(equalToConstant: standartInset*12).isActive = true
        
        statePickerView.delegate = self
        statePickerView.dataSource = self
        statePickerView.topAnchor.constraint(equalTo: illnessSelectButton.bottomAnchor).isActive = true
        statePickerView.leadingAnchor.constraint(equalTo: confirmationPickerView.trailingAnchor).isActive = true
        statePickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset/2).isActive = true
        statePickerView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        statePickerView.bottomAnchor.constraint(equalTo: confirmationPickerView.bottomAnchor).isActive = true
    }
    
    private func setUpDateTimePiker() {
        contentView.addSubview(dateTimePiker)
        dateTimePiker.topAnchor.constraint(equalTo: confirmationPickerView.bottomAnchor).isActive = true
        dateTimePiker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset/2).isActive = true
        dateTimePiker.heightAnchor.constraint(equalToConstant: standartInset*10).isActive = true
        dateTimePiker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset/2).isActive = true
        dateTimePiker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
}
