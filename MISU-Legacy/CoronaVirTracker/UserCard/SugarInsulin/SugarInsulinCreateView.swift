//
//  SugarInsulinCreateView.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 9/20/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SugarInsulinCreateView: EditView {
    let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 20, color: .black, alignment: .center)
    let valueTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 16)
        tf.placeholder = "-.-"
        tf.keyboardType = .numbersAndPunctuation
        return tf
    }()
        
    let dateTimePiker: UIDatePicker = {
        let dtPiker = UIDatePicker()
        dtPiker.translatesAutoresizingMaskIntoConstraints = false
        dtPiker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            dtPiker.preferredDatePickerStyle = .wheels
        }
        dtPiker.maximumDate = Date()
        return dtPiker
    }()
    
    var healthParamModel: HealthParameterModel? {
        get {
            guard let txt = valueTextField.text else { return nil }
            guard let value = Float(txt.replacingOccurrences(of: ",", with: ".")) else { return nil }
            return .init(id: -1, value: value, date: dateTimePiker.date)
        }
    }
    
    init(frame: CGRect, type: SugarInsulineEnum) {
        super.init(frame: frame)
        
        switch type {
        case .sugar:
            titleLabel.text = NSLocalizedString("Blood sugar (mmol/L)", comment: "")
        case .insuline:
            titleLabel.text = NSLocalizedString("Insulin (ml)", comment: "")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - Overrides
extension SugarInsulinCreateView {
    override func setUpAdditionalViews() {
        saveButton.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        
        setUpTitleViews()
        setUpTextView()
        setUpDateTimePiker()
    }
    
    override func saveAction() -> Bool {
        return true
    }
}



// MARK: - TextField Delegate
extension SugarInsulinCreateView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}



// MARK: - keyboard observer methods
extension SugarInsulinCreateView {
    override func keyboardWillShowAction(keyboardFrame: CGRect) {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -keyboardFrame.height+cancelButton.frame.height, duration: 0.3)
    }
    
    override func keyboardWillHideAction() {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -standartInset, duration: 0.3)
    }
}



// MARK: - Additional views set up
extension SugarInsulinCreateView {
    private func setUpTitleViews() {
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    private func setUpTextView() {
        contentView.addSubview(valueTextField)
        
        valueTextField.delegate = self
        valueTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset).isActive = true
        valueTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*2).isActive = true
        valueTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*2).isActive = true
    }
    
    private func setUpDateTimePiker() {
        contentView.addSubview(dateTimePiker)
        
        dateTimePiker.topAnchor.constraint(equalTo: valueTextField.bottomAnchor, constant: standartInset/2).isActive = true
        dateTimePiker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*2).isActive = true
        dateTimePiker.heightAnchor.constraint(equalToConstant: standartInset*10).isActive = true
        dateTimePiker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*2).isActive = true
        dateTimePiker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
}
