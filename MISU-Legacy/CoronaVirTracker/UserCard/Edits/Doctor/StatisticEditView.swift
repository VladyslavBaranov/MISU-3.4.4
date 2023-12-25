//
//  StatisticEditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 24.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class StatisticEditView: EditView {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Hospital statistics", comment: ""), fontSize: 14, color: .black, alignment: .center)
    let greenPointImageView: UIImageView = .makeImageView("greenHealthPin")
    let greenTextField: UIUnderLinedTextField = UIUnderLinedTextField()
    let yellowPointImageView: UIImageView = .makeImageView("yellowHealthPin")
    let yellowTextField: UIUnderLinedTextField = UIUnderLinedTextField()
    let redPointImageView: UIImageView = .makeImageView("redHealthPin")
    let redTextField: UIUnderLinedTextField = UIUnderLinedTextField()
    
    var statisticValue: HealthStatisticModel {
        get {
            var stat = HealthStatisticModel(well: 0, weak: 0, ill: 0, dead: 0)
            if let txt = greenTextField.text, let count = Int(txt) {
                stat.well = count
            }
            if let txt = yellowTextField.text, let count = Int(txt) {
                stat.weak = count
            }
            if let txt = redTextField.text, let count = Int(txt) {
                stat.ill = count
            }
            return stat
        }
        set {
            if newValue.well != 0 { greenTextField.text = String(newValue.well) }
            if newValue.weak != 0 { yellowTextField.text = String(newValue.weak) }
            if newValue.ill != 0 { redTextField.text = String(newValue.ill) }
        }
    }
}
 


// MARK: - Overrides
extension StatisticEditView {
    override func setUpAdditionalViews() {
        setUpViews()
        dataSetUp()
    }
    
    override func saveAction() -> Bool {
        if UCardSingleManager.shared.user.doctor?.statistic != statisticValue {
            let old = UCardSingleManager.shared.user
            UCardSingleManager.shared.user.doctor?.statistic = statisticValue
            UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                if success { DispatchQueue.main.async { self.completionAction?(true) } }
            }
        }
        return true
    }
    
    override func keyboardWillShowAction(keyboardFrame: CGRect) {
        let newY = keyboardFrame.height-saveButton.frame.height-cancelButton.frame.height-standartInset
        contentView.animateMove(y: -newY, duration: 0.3)
    }
    
    override func keyboardWillHideAction() {
        contentView.animateMove(y: 0, duration: 0.3)
    }
}



// MARK: - Other methods
extension StatisticEditView {
}



// MARK: - Additional views set up
extension StatisticEditView {
    private func dataSetUp() {
        if let stat = UCardSingleManager.shared.user.doctor?.statistic {
            statisticValue = stat
        }
    }
    
    private func setUpViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(greenPointImageView)
        contentView.addSubview(greenTextField)
        contentView.addSubview(yellowPointImageView)
        contentView.addSubview(yellowTextField)
        contentView.addSubview(redPointImageView)
        contentView.addSubview(redTextField)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        let statText = [statisticValue.well, statisticValue.weak, statisticValue.ill]
        var prevView: UIView = titleLabel
        var prevViewAnchor = titleLabel.bottomAnchor
        let placeholders = ["Healthy", "Suspicious", "Sick"]
        let textFields = [greenTextField, yellowTextField, redTextField]
        let images = [greenPointImageView, yellowPointImageView, redPointImageView]
        
        (0...images.count-1).forEach { i in
            textFields[i].keyboardType = .numberPad
            textFields[i].placeholder = NSLocalizedString(placeholders[i], comment: "")
            textFields[i].delegate = self
            textFields[i].tag = prevView.tag + 1
            
            if statText[i] != 0 {
                textFields[i].text = String(describing: statText[i])
            }
            
            textFields[i].topAnchor.constraint(equalTo: prevViewAnchor, constant: standartInset).isActive = true
            textFields[i].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
            textFields[i].leadingAnchor.constraint(equalTo: images[i].trailingAnchor, constant: standartInset/2).isActive = true
            textFields[i].setContentHuggingPriority(.init(1001), for: .vertical)
            
            images[i].topAnchor.constraint(equalTo: textFields[i].topAnchor).isActive = true
            images[i].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
            images[i].bottomAnchor.constraint(equalTo: textFields[i].bottomAnchor).isActive = true
            images[i].widthAnchor.constraint(equalTo: images[i].heightAnchor, multiplier: 0.643).isActive = true
            
            prevView = textFields[i]
            prevViewAnchor = prevView.bottomAnchor
        }
        
        textFields.last?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset*2).isActive = true
    }
}
