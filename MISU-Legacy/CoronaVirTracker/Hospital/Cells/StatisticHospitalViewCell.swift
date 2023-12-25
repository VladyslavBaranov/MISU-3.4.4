//
//  StatisticHospitalViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class StatisticHospitalViewCell: CustomCVCell {
    let mainStack: UIStackView = .createCustom(axis: .vertical, distribution: .fillEqually)
    
    let hPramViews: [UIView] = {
        var ivs: [UIView] = []
        HealthStatusEnum.allCases.forEach { hStatus in
            let imgV = UIView.createCustom(bgColor: .white)
            imgV.setCustomCornerRadius()
            ivs.append(imgV)
        }
        return ivs
    }()
    
    let imageViews: [UIImageView] = {
        var ivs: [UIImageView] = []
        HealthStatusEnum.allCases.forEach { hStatus in
            ivs.append(.makeImageView(hStatus.imageName))
        }
        return ivs
    }()
    
    let nameTitles: [UILabel] = {
        var ivs: [UILabel] = []
        HealthStatusEnum.allCases.forEach { hStatus in
            ivs.append(.createTitle(text: hStatus.localized, fontSize: 14))
        }
        return ivs
    }()
    
    let numberTitles: [UILabel] = {
        var ivs: [UILabel] = []
        HealthStatusEnum.allCases.forEach { hStatus in
            ivs.append(.createTitle(text: "-", fontSize: 16, weight: .medium))
        }
        return ivs
    }()
    
    let arrowIViews: [UIImageView] = {
        var ivs: [UIImageView] = []
        HealthStatusEnum.allCases.forEach { hStatus in
            ivs.append(.makeImageView("sendImage", withRenderingMode: .alwaysTemplate, tintColor: .lightGray))
        }
        return ivs
    }()
    
    //sendImage
    
    var statistic: HealthStatisticModel? {
        didSet {
            guard let st = statistic else {return}
            numberTitles[safe: HealthStatusEnum.well.rawValue]?.text = String(st.well)
            numberTitles[safe: HealthStatusEnum.weak.rawValue]?.text = String(st.weak)
            numberTitles[safe: HealthStatusEnum.ill.rawValue]?.text = String(st.ill)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    private func initSetUp() {
        //backgroundColor = .white
        //setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 25)
        addCustomShadow()
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        addSubview(mainStack)
        mainStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        hPramViews.enumerated().forEach { index, hView in
            mainStack.addSubview(hView)
            hView.addSubview(imageViews[index])
            hView.addSubview(nameTitles[index])
            hView.addSubview(numberTitles[index])
            hView.addSubview(arrowIViews[index])
            mainStack.addArrangedSubview(hView)
            
            hView.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
            
            imageViews[index].centerYAnchor.constraint(equalTo: hView.centerYAnchor).isActive = true
            imageViews[index].leadingAnchor.constraint(equalTo: hView.leadingAnchor, constant: standartInset).isActive = true
            imageViews[index].widthAnchor.constraint(equalTo: nameTitles[index].heightAnchor, multiplier: 1.8).isActive = true
            imageViews[index].heightAnchor.constraint(equalTo: nameTitles[index].heightAnchor, multiplier: 1.8).isActive = true
            
            nameTitles[index].centerYAnchor.constraint(equalTo: hView.centerYAnchor).isActive = true
            nameTitles[index].leadingAnchor.constraint(equalTo: imageViews[index].trailingAnchor, constant: standartInset).isActive = true
            nameTitles[index].trailingAnchor.constraint(equalTo: numberTitles[index].leadingAnchor, constant: -standartInset).isActive = true
            nameTitles[index].topAnchor.constraint(equalTo: hView.topAnchor, constant: standart24Inset).isActive = true
            nameTitles[index].bottomAnchor.constraint(equalTo: hView.bottomAnchor, constant: -standart24Inset).isActive = true
            
            
            nameTitles[index].setContentHuggingPriority(.defaultHigh, for: .vertical)
            nameTitles[index].setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            nameTitles[index].setContentHuggingPriority(.init(100), for: .horizontal)
            nameTitles[index].setContentCompressionResistancePriority(.init(100), for: .horizontal)
            
            arrowIViews[index].centerYAnchor.constraint(equalTo: hView.centerYAnchor).isActive = true
            arrowIViews[index].trailingAnchor.constraint(equalTo: hView.trailingAnchor, constant: -standartInset).isActive = true
            arrowIViews[index].widthAnchor.constraint(equalTo: nameTitles[index].heightAnchor, multiplier: 1.2).isActive = true
            arrowIViews[index].heightAnchor.constraint(equalTo: nameTitles[index].heightAnchor, multiplier: 1.2).isActive = true
            
            numberTitles[index].centerYAnchor.constraint(equalTo: hView.centerYAnchor).isActive = true
            numberTitles[index].trailingAnchor.constraint(equalTo: arrowIViews[index].leadingAnchor, constant: -standartInset).isActive = true
        }
    }
    
    override func getSize(cv: UICollectionView) -> CGSize {
        let cell = StatisticHospitalViewCell()
        var h: CGFloat = cell.standartInset/2 + CGFloat(cell.nameTitles.count-1)
        
        cell.nameTitles.forEach { nTitle in
            nTitle.sizeToFit()
            h += nTitle.frame.height + cv.standart24Inset*2
        }
        
        return .init(width: cv.frame.width-cv.standartInset, height: h)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
