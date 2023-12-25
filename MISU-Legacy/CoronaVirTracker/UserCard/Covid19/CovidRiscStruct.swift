//
//  CovidRiscStruct.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum CovidRiscStruct: EnumKit, CaseIterable {
    case weight
    case height
    case index
    case age
    case sex
    case apn
    
    var statusLabel: UILabel? {
        switch self {
        case .height, .weight:
            return nil
        default:
            return .createTitle(text: "?", fontSize: 24, weight: .medium, color: .gray, alignment: .center)
        }
    }
    
    var editView: UIView? {
        switch self {
        case .weight, .height:
            return UITextField.custom(placeholder: NSLocalizedString("Edit", comment: ""), textColor: .lightGray, keyboardType: .decimalPad)
        case .index:
            return UILabel.createTitle(text: NSLocalizedString("Input your weight and Height", comment: ""), fontSize: 16, color: .gray)
        case .age, .sex, .apn: 
            return UIButton.createCustom(title: NSLocalizedString("Edit", comment: ""), color: .clear, fontSize: 16, textColor: .gray, shadow: false, customContentEdgeInsets: false, setCustomCornerRadius: false, zeroInset: true)
        }
    }
    
    var iconView: UIImageView {
        let img = UIImageView.makeImageView(self.icon, contentMode: .left)
        img.customWidthAnchorConstraint = img.widthAnchor.constraint(equalToConstant: 32)
        img.customWidthAnchorConstraint?.isActive = true
        img.customHeightAnchorConstraint = img.heightAnchor.constraint(equalToConstant: 48)
        img.customHeightAnchorConstraint?.isActive = true
        return img
    }
    
    var titleLabel: UILabel {
        return .createTitle(text: self.titleLocalized, fontSize: 16)
    }
    
    var icon: UIImage? {
        return UIImage(named: iconName)?.scaleProportionalyTo(height: 24)
    }
    
    var titleLocalized: String {
        return NSLocalizedString(title, comment: "")
    }
    
    var iconName: String {
        switch self {
        case .weight:
            return "WeightCRiskIcon"
        case .height:
            return "HeightCRiskIcon"
        case .index:
            return "IndexCRiskIcon"
        case .age:
            return "AgeCRiskIcon"
        case .sex:
            return "SexCRiskIcon"
        case .apn:
            return "APNCRiskIcon"
        }
    }
    
    var title: String {
        switch self {
        case .weight:
            return "Weight"
        case .height:
            return "Height (cm)"
        case .index:
            return "Body mass index"
        case .age:
            return "Age"
        case .sex:
            return "Sex"
        case .apn:
            return "Sleep apnea"
        }
    }
}



enum RiskGroup {
    case inRisk
    case noRisk
    case undefined
    
    init(inGroup: Bool?) {
        switch inGroup {
        case true:
            self = .inRisk
        case false:
            self = .noRisk
        default:
            self = .undefined
        }
    }
    
    init(isNormParam: Bool?) {
        switch isNormParam {
        case true:
            self = .noRisk
        case false:
            self = .inRisk
        default:
            self = .undefined
        }
    }
    
    
    var localized: String {
        return NSLocalizedString(title, comment: "")
    }
    
    var localizedForView: String {
        if self == .undefined { return NSLocalizedString("Fill in all the fields below", comment: "") }
        return NSLocalizedString(title, comment: "")
    }
    
    var color: UIColor {
        switch self {
        case .inRisk:
            return UIColor.appDefault.redNew
        case .noRisk:
            return UIColor.appDefault.green
        default:
            return .lightGray
        }
    }
    
    var colorForParams: UIColor {
        switch self {
        case .inRisk:
            return UIColor.appDefault.yellow
        case .noRisk:
            return UIColor.appDefault.green
        default:
            return .lightGray
        }
    }
    
    var colorForStatusBG: UIColor {
        switch self {
        case .inRisk:
            return UIColor.appDefault.redNika
        case .noRisk:
            return .white
        default:
            return UIColor.appDefault.blueNika
        }
    }
    
    var colorForStatusLabel: UIColor {
        switch self {
        case .inRisk:
            return .white
        case .noRisk:
            return UIColor.appDefault.green
        default:
            return .white
        }
    }
    
    var colorForStatusShadow: UIColor {
        switch self {
        case .inRisk:
            
            return colorForStatusBG
        case .noRisk:
            return .black
        default:
            return colorForStatusBG
        }
    }
    
    var statusText: String {
        switch self {
        case .inRisk:
            return NSLocalizedString("The value is in group of risk", comment: "")
        case .noRisk:
            return NSLocalizedString("The value is normal", comment: "")
        default: 
            return NSLocalizedString("Fill in the information", comment: "")
        }
    }
    
    func addShadow(_ view: UIView?) {
        view?.removeShadow()
        switch self {
        case .noRisk:
            view?.addCustomShadow()
        default:
            view?.addShadow(radius: 10, offset: .zero, opacity: 0.6, color: colorForStatusShadow)
        }
    }
    
    var image: UIImage? {
        switch self {
        case .inRisk:
            return HealthStatusEnum.ill.getSmileImage()
        case .noRisk:
            return HealthStatusEnum.well.getSmileImage()
        default:
            return UIImage(named: "greyHealthSmile")
        }
    }
    
    var title: String {
        switch self {
        case .inRisk:
            return "You are in group of risk"
        case .noRisk:
            return "You are not in group of risk"
        default:
            return "Give answers to question"
        }
    }
    
    var paramStatusTitle: String {
        switch self {
        case .inRisk:
            return "!"
        case .noRisk:
            return "✓"
        default:
            return "?"
        }
    }
}
