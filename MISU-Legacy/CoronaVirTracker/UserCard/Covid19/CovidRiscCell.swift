//
//  CovidRiscCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 11.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CovidRiscCVCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? { return self.getAddress() }
    
    let mainStack: UIStackView = .createCustom(axis: .vertical)
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Covid-19", comment: ""), fontSize: 16, alignment: .center)
    let statusImage: UIImageView = .makeImageView(RiskGroup.undefined.image)
    let statusLabel: UILabel = .createTitle(text: RiskGroup.undefined.localized, fontSize: 16, alignment: .center)
    let testButton: UIButton = .createCustom(title: NSLocalizedString("Determine the risk", comment: ""), color: UIColor.appDefault.redNew, customContentEdgeInsets: false)
    
    var pId: Int?
    var covidInfo: CovidModel = .init() {
        didSet {
            statusImage.image = covidInfo.riskGroup.image
            statusLabel.text = covidInfo.riskGroup.localized
        }
    }
    
    init() {
        super.init(frame: .zero)
        initSetUp()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    func getInfo() {
        prepareViewsBeforReqest(activityView: self)
        CovidManager.shared.getInfo(uid: pId) { covidInfo_, error_ in
            self.enableViewsAfterReqest()
            if let ci = covidInfo_?.first {
                DispatchQueue.main.async {
                    self.covidInfo = ci
                }
            }
            if let er = error_ {
                print("Get covid risk ERROR: \(er)")
            }
        }
    }
    
    @objc func passTestAction() {
        let vc = CovidRiscView()
        vc.covidInfo = covidInfo
        vc.pId = pId
        vc.parentCell = self
        controller()?.navigationController?.present(vc, animated: true)
    }
    
    func initSetUp() {
        backgroundColor = .white
        setCustomCornerRadius()
        addCustomShadow()
        addSubview(mainStack)
        addSubview(testButton)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(statusImage)
        mainStack.addArrangedSubview(statusLabel)
        mainStack.addArrangedSubview(testButton)
        testButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset/2).isActive = true
        testButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset/2).isActive = true
        testButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        testButton.addTarget(self, action: #selector(passTestAction), for: .touchUpInside)
        //mainStack.customCentrConstraints(on: self, inset: 8)
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset/2).isActive = true
        mainStack.topAnchor.constraint(equalTo: topAnchor, constant: standartInset/2).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset/2).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standartInset/2).isActive = true
        
        statusImage.setContentCompressionResistancePriority(.init(100), for: .vertical)
        statusImage.setContentHuggingPriority(.init(100), for: .vertical)
        statusLabel.adjustsFontSizeToFitWidth = true
    }
    
    static func getHeight() -> CGFloat {
        let cell = CovidRiscCVCell()
        return cell.standartInset*4
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        initSetUp()
    }
}
