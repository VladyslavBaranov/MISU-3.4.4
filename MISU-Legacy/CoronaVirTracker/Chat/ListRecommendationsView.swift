//
//  ListRecommendationsView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 18.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ListRecommendationsView: EditView {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Your recommendations for patient", comment: ""), fontSize: 14, color: .black, alignment: .center)
    let valueTextField: UITextView = {
        let tf = UITextView()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 16)
        tf.cornerRadius = 10
        tf.addBorder(radius: 1, color: .lightGray)
        return tf
    }()
    
    var reccmmendationModel: SendMessage? {
        get {
            guard let mssg = valueTextField.text, !mssg.isEmpty else { return nil }
            return .init(sender: UCardSingleManager.shared.user.id, message: mssg, recom: true)
        }
    }
}



// MARK: - Overrides
extension ListRecommendationsView {
    override func setUpAdditionalViews() {
        saveButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        setUpSubViews()
    }
    
    override func saveAction() -> Bool {
        return true
    }
}



// MARK: - keyboard observer methods
extension ListRecommendationsView {
    override func keyboardWillShowAction(keyboardFrame: CGRect) {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -keyboardFrame.height+cancelButton.frame.height, duration: 0.3)
    }
    
    override func keyboardWillHideAction() {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -standartInset, duration: 0.3)
    }
}



// MARK: - Additional views set up
// don't do this
extension ListRecommendationsView {
    private func setUpSubViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueTextField)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        valueTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset).isActive = true
        valueTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        valueTextField.heightAnchor.constraint(equalToConstant: (valueTextField.font?.lineHeight ?? standartInset) * 13).isActive = true
        valueTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        valueTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
}
