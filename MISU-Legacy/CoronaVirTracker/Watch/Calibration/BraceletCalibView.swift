//
//  BraceletCalibView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class BraceletCalibView: UIView {
    let imageView: UIImageView = .makeImageView("infoCalibBracUkr")
    let textView: UILabel = .createTitle(
        text: "• \(NSLocalizedString("Select “Pressure” on the bracelet", comment: ""))\n\n• \(NSLocalizedString("Press the button as shown in the image", comment: ""))\n\n• \(NSLocalizedString("The data will be received automatically", comment: ""))",
        fontSize: 16, numberOfLines: 8)
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        initSetUp()
    }
    
    func getIndicators(_ completion: ((_ param: HealthParameterModel)->Void)?) {
        WatchSinglManager.shared.readCurrentBP(completion)
    }
    
    func initSetUp() {
        let mainStack = UIStackView.createCustom([imageView, textView], axis: .vertical, spacing: standartInset)
        
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

