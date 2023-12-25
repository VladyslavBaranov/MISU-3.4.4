//
//  SyndromAPNEditView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class SyndromAPNEditView: BaseEditView {
    let contentStack: UIStackView = .createCustom(axis: .vertical, spacing: 32)
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Have you ever been diagnosed with sleep apnea?", comment: ""), fontSize: 20, color: UIColor.appDefault.redNew, alignment: .center, numberOfLines: 3)
    let textLabel: UILabel = .createTitle(text: NSLocalizedString("• Apnea or temporary cessation of respiratory movements during sleep.\n\n• The most common symptom is snoring in sleep", comment: ""), fontSize: 16, numberOfLines: 55)
    let noDButton: UIButton = .createCustom(title: NSLocalizedString("No, undiagnosed", comment: ""), color: .white,
                                            fontSize: 16, weight: .medium, textColor: .systemBlue,
                                            shadow: false, btnType: .system)
    
    var isAPNSyndr: Bool?
    
    override func setUp() {
        super.setUp()
        
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(textLabel)
        contentStack.customCentrConstraints(on: contentView, inset: .init(top: standartInset*2, left: standartInset*2,
                                                                          bottom: standartInset*2, right: standartInset*2))
        saveButton.setTitle(NSLocalizedString("Yes, diagnosed", comment: ""), for: .normal)
        mainStack.insertArrangedSubview(noDButton, at: 2)
        noDButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        noDButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
    }
    
    override func saveButtonAction(_ sender: UIButton) {
        switch sender {
        case saveButton:
            isAPNSyndr = true
        case noDButton:
            isAPNSyndr = false
        default:
            isAPNSyndr = nil
        }
        super.saveButtonAction(sender)
    }
}
