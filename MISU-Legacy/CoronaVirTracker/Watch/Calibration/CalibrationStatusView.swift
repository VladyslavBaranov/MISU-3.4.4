//
//  CalibrationStatusView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CalibrationStatusView: UIView, RequestUIController {
    func uniqeKeyForStore() -> String? { return getAddress() }
    
    let imageView: UIImageView = .makeImageView(UIImage(named: "doneFamIcon")?.scaleTo(89), withRenderingMode: .alwaysTemplate, tintColor: UIColor.appDefault.redNew)
    let textView: UILabel = .createTitle(
        text: NSLocalizedString("Processing ...", comment: ""),
        fontSize: 16, weight: .bold, numberOfLines: 3)
    let additionalLabel: UILabel = .createTitle(
        text: NSLocalizedString("All pressure indicators will be individually adjusted to your characteristics", comment: ""),
        fontSize: 16, numberOfLines: 10)
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        initSetUp()
    }
    
    func sendCalibration(tonom: HealthParameterModel, bracelet: HealthParameterModel, completion: ((_ success: Bool, _ errorMsg: String?)->Void)?) {
        imageView.image = nil
        textView.text = NSLocalizedString("Processing ...", comment: "")
        prepareViewsBeforReqest(activityView: imageView)
        HealthParamsManager.shared.calibrate(.init(tonom: tonom, bracelet: bracelet )) { success, error in
            self.enableViewsAfterReqest()
            print("### sendCalibration \(String(describing: success))")
            print("### sendCalibration ERROR \(String(describing: error))")
            
            if success != nil {
                completion?(true, error?.message)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "doneFamIcon")?.withRenderingMode(.alwaysTemplate)
                    self.textView.text = NSLocalizedString("Successful calibration", comment: "")
                }
            }
            
            if let er = error {
                completion?(false, er.message)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "unsuccessIcon")?.withRenderingMode(.alwaysTemplate)
                    self.textView.text = er.message
                }
            }
        }
        
    }
    
    func getIndicators(_ completion: ((_ param: HealthParameterModel)->Void)?) {
        WatchSinglManager.shared.readCurrentBP(completion)
    }
    
    func initSetUp() {
        let mainStack = UIStackView.createCustom([imageView, textView, additionalLabel], axis: .vertical, spacing: standart24Inset)
        imageView.setContentCompressionResistancePriority(.init(100), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        imageView.setContentHuggingPriority(.init(100), for: .vertical)
        imageView.setContentHuggingPriority(.init(100), for: .horizontal)
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
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

