//
//  GeneralInfoPatientEditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 09.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class GeneralInfoPatientEditView: BaseEditView {
    let contentStack: UIStackView = .createCustom(axis: .vertical, distribution: .fill, spacing: 24)
    let statusLabel: UILabel = .createTitle(text: NSLocalizedString("How do you feel today?", comment: ""), fontSize: 14, color: .lightGray, alignment: .center)
    let pointsStack: UIStackView = .createCustom(distribution: .fillEqually, spacing: 24)
    let greenPointImage: UIImageView = .makeImageView("greenHealthPin")
    let yellowPointImage: UIImageView = .makeImageView("yellowHealthPin")
    let redPointImage: UIImageView = .makeImageView("redHealthPin")
    
    let parametersTitle: UILabel = .createTitle(text: NSLocalizedString("Other settings:", comment: ""), fontSize: 14, color: .lightGray, alignment: .center)
    let heightIcon: UIImageView = CovidRiscStruct.height.iconView
    let heightTF: UITextField = .custom(placeholder: NSLocalizedString("Height", comment: ""), keyboardType: .decimalPad)
    let weightIcon: UIImageView = CovidRiscStruct.weight.iconView
    let weightTF: UITextField = .custom(placeholder: NSLocalizedString("Weight", comment: ""), keyboardType: .decimalPad)
    let sexIcon: UIImageView = CovidRiscStruct.sex.iconView
    let sexLabel: UILabel = .createTitle(text: CovidRiscStruct.sex.titleLocalized, fontSize: 16)
    let ageIcon: UIImageView = CovidRiscStruct.age.iconView
    let ageLabel: UILabel = .createTitle(text: CovidRiscStruct.age.titleLocalized, fontSize: 16)
    
    var healthStatusValue: HealthStatus? {
        didSet {
            guard let health = healthStatusValue else { return }
            
            switch health {
            case .well:
                self.selectStatusImage(greenPointImage)
            case .weak:
                self.selectStatusImage(yellowPointImage)
            case .ill:
                self.selectStatusImage(redPointImage)
            default:
                return
            }
        }
    }
    
    var sexValue: Gender? {
        didSet {
            guard let sx = sexValue?.localized else { return }
            sexLabel.text = sx
        }
    }
    
    var ageValue: Date? {
        didSet {
            guard let dt = ageValue?.getYears() else { return }
            ageLabel.text = "\(dt)"
        }
    }
    
    override func setUp() {
        super.setUp()
        
        contentView.addSubview(contentStack)
        contentStack.fixedEdgesConstraints(on: contentView, inset: .init(top: standart24Inset, left: standart24Inset,
                                                                         bottom: standart24Inset, right: standart24Inset))
        contentStack.addArrangedSubview(statusLabel)
        contentStack.addArrangedSubview(pointsStack)
        pointsStack.addArrangedSubview(greenPointImage)
        pointsStack.addArrangedSubview(yellowPointImage)
        pointsStack.addArrangedSubview(redPointImage)
        
        greenPointImage.addTapRecognizer(self, action: #selector(statusImageAction(_:)))
        yellowPointImage.addTapRecognizer(self, action: #selector(statusImageAction(_:)))
        redPointImage.addTapRecognizer(self, action: #selector(statusImageAction(_:)))
        
        [greenPointImage, yellowPointImage, redPointImage].forEach { iView in
            iView.heightAnchor.constraint(equalTo: iView.widthAnchor, multiplier: iView.imageHeightToWidthMultiplier()).isActive = true
        }
        
        contentStack.setCustomSpacing(standart24Inset*2, after: pointsStack)
        
        contentStack.addArrangedSubview(parametersTitle)
        
        contentStack.setCustomSpacing(standartInset, after: parametersTitle)
        
        [(heightIcon, heightTF), (weightIcon, weightTF), (sexIcon, sexLabel), (ageIcon, ageLabel)].forEach { iconV, tfView in
            iconV.addTapRecognizer(self, action: #selector(iconTapAction(_:)))
            tfView.setContentHuggingPriority(.init(100), for: .horizontal)
            iconV.customHeightAnchorConstraint?.constant = standartInset*2
            let sv = UIStackView.createCustom([iconV, tfView], distribution: .fill, spacing: 0, alignment: .center)
            contentStack.addArrangedSubview(sv)
            sv.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true
        }
        
        [sexLabel, ageLabel].forEach({ $0.addTapRecognizer(self, action: #selector(iconTapAction(_:))) })
        
        healthStatusValue = UCardSingleManager.shared.user.profile?.status
        
        if let h = UCardSingleManager.shared.user.profile?.height?.truncate(places: 1) {
            heightTF.text = "\(h)"
        }
        if let w = UCardSingleManager.shared.user.profile?.weight?.truncate(places: 1) {
            weightTF.text = "\(w)"
        }
        
        sexValue = UCardSingleManager.shared.user.profile?.gender
            
        ageValue = UCardSingleManager.shared.user.profile?.birthdayDate
    }
}
 


// MARK: - Overrides
extension GeneralInfoPatientEditView {
    override func saveButtonAction(_ sender: UIButton) {
        var isEdited = false
        
        let old = UCardSingleManager.shared.user
        
        if UCardSingleManager.shared.user.profile?.status != healthStatusValue {
            UCardSingleManager.shared.user.profile?.status = healthStatusValue
            isEdited = true
        }
        
        let hValue = Double(heightTF.text?.replacingOccurrences(of: ",", with: ".") ?? "")?.truncate(places: 1)
        if UCardSingleManager.shared.user.profile?.height != hValue {
            UCardSingleManager.shared.user.profile?.height = hValue
            isEdited = true
        }
        
        let wValue = Double(weightTF.text?.replacingOccurrences(of: ",", with: ".") ?? "")?.truncate(places: 1)
        if UCardSingleManager.shared.user.profile?.weight != wValue {
            UCardSingleManager.shared.user.profile?.weight = wValue
            isEdited = true
        }
        
        if UCardSingleManager.shared.user.profile?.gender != sexValue {
            UCardSingleManager.shared.user.profile?.gender = sexValue ?? .none
            isEdited = true
        }
        
        if UCardSingleManager.shared.user.profile?.birthdayDate != ageValue {
            UCardSingleManager.shared.user.profile?.birthdayDate = ageValue
            isEdited = true
        }
        
        if isEdited {
            UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true)  { success in
                if success { DispatchQueue.main.async { self.completionAction?(true) } }
            }
        }
        
        super.saveButtonAction(sender)
    }
    
    override func keyboardWillShowAction(keyboardFrame: CGRect) {
        let const: CGFloat = -keyboardFrame.height+standartInset*2+cancelButton.frame.height
        mainStack.animateConstraint(mainStack.customBottomAnchorConstraint, constant: const, duration: 0.1)
    }
    
    override func keyboardWillHideAction() {
        mainStack.animateConstraint(mainStack.customBottomAnchorConstraint, constant: -standartInset, duration: 0.1)
    }
}
    


// MARK: - Recognizer Actions
extension GeneralInfoPatientEditView {
    @objc func iconTapAction(_ sender: UITapGestureRecognizer) {
        var av = heightIcon
        var txt = ""
        switch sender.view {
        case heightIcon:
            av = heightIcon
            txt = NSLocalizedString("Height", comment: "")
        case weightIcon:
            av = weightIcon
            txt = NSLocalizedString("Weight", comment: "")
        case sexIcon:
            av = sexIcon
            txt = NSLocalizedString("Sex", comment: "")
        case ageIcon:
            av = ageIcon
            txt = NSLocalizedString("Age", comment: "")
        case sexLabel:
            let vw = SexEditView(frame: frame)
            if let sexInt = UCardSingleManager.shared.user.profile?.gender.rawValue {
                vw.selectedSex = SexEnum(num: sexInt)
            } else {
                vw.selectedSex = SexEnum.notSelected
            }
            vw.show { save in
                if !save { return }
                DispatchQueue.main.async {
                    self.sexValue = vw.selectedSex.translate()
                }
            }
            return
        case ageLabel:
            let vw = AgeEditView(frame: frame)
            vw.selectedDate = UCardSingleManager.shared.user.profile?.birthdayDate ?? Date()
            vw.show { save in
                DispatchQueue.main.async {
                    self.ageValue = vw.selectedDate
                }
            }
            return
        default:
            return
        }
        SmallMessageView().showOn(self, anchorView: av, text: txt, position: .topTrailing)
    }
    
    @objc func statusImageAction(_ sender: UIGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        
        unselectStatusImage(healthStatusValue)
        switch imageView {
        case greenPointImage:
            healthStatusValue = .well
        case yellowPointImage:
            healthStatusValue = .weak
        case redPointImage:
            healthStatusValue = .ill
        default:
            return
        }
    }
}



// MARK: - Other methods
extension GeneralInfoPatientEditView {
    private func selectStatusImage(_ imageView: UIImageView) {
        imageView.animateScaleTransform(x: 1.1, y: 1.1, duration: 0.1)
        imageView.addShadow(radius: 3, offset: CGSize(width: 3, height: 3), opacity: 0.3, color: .black)
    }
    
    private func unselectStatusImage(_ status: HealthStatus?) {
        switch status {
        case .well?:
            makeUnSelected(greenPointImage)
        case .weak?:
            makeUnSelected(yellowPointImage)
        case .ill?:
            makeUnSelected(redPointImage)
        default:
            return
        }
    }
    
    private func makeUnSelected(_ view: UIView) {
        view.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        view.removeShadow()
    }
}
