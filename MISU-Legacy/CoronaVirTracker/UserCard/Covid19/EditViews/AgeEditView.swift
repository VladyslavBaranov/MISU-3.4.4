//
//  AgeEditView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 11.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class AgeEditView: BaseEditView {
    let contentStack: UIStackView = .createCustom(axis: .vertical)
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Age", comment: ""), fontSize: 24, alignment: .center)
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
    
    var selectedDate: Date {
        get {
            return dateTimePiker.date
        }
        set {
            dateTimePiker.date = newValue
        }
    }
    
    override func setUp() {
        super.setUp()
        
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(dateTimePiker)
        contentStack.customCentrConstraints(on: contentView)
    }
}
