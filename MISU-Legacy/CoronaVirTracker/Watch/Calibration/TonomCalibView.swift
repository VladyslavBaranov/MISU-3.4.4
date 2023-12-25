//
//  TonomCalibView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 29.05.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class TonomCalibView: UIView {
    let imageView: UIImageView = .makeImageView("deviceCalibTonom")
    let textView: UILabel = .createTitle(text: NSLocalizedString("Measure the pressure with a tonometer and enter result:", comment: ""), fontSize: 16, alignment: .center, numberOfLines: 3)
    let firstTextField: UITextField = .custom(placeholder: "120", fontSize: 18, keyboardType: .numberPad)
    let devidLine: UIView = .createCustom(bgColor: .gray)
    let secondTextField: UITextField = .custom(placeholder: "80", fontSize: 18, keyboardType: .numberPad)
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        initSetUp()
    }
    
    func getIndicators() -> HealthParameterModel? {
        guard let fText = firstTextField.text, !fText.isEmpty, let hight = Float(fText) else { return nil }
        guard let sText = secondTextField.text, !sText.isEmpty, let low = Float(sText) else { return nil }
        return .init(id: -1, value: hight, additionalValue: low, date: Date())
    }
    
    func alertAnim() {
        firstTextField.animateShake(intensity: 3, duration: 0.3)
        secondTextField.animateShake(intensity: 3, duration: 0.3)
        devidLine.animateShake(intensity: 3, duration: 0.3)
    }
    
    func initSetUp() {
        let subStack = UIStackView.createCustom([firstTextField, devidLine, secondTextField], spacing: standartInset)
        let mainStack = UIStackView.createCustom([imageView, textView, subStack], axis: .vertical, spacing: standartInset)
        
        devidLine.widthAnchor.constraint(equalToConstant: 2).isActive = true
        devidLine.heightAnchor.constraint(equalToConstant: standartInset*2).isActive = true
        devidLine.cornerRadius = 1
        
        imageView.setContentCompressionResistancePriority(.init(100), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        imageView.setContentHuggingPriority(.init(100), for: .vertical)
        imageView.setContentHuggingPriority(.init(100), for: .horizontal)
        
        addSubview(mainStack)
        mainStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mainStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        mainStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSetUp()
    }
}

