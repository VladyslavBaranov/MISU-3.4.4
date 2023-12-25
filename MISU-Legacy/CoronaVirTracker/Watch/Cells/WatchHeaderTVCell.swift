//
//  WatchHeaderTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 05.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import TrusangBluetooth

class WatchHeaderTVCell: UITableViewCell {
    let watchIconImage: UIImageView = .makeImageView("watchHeaderIcon")
    let batteryPowerLabel: UILabel = .createTitle(text: "-%", fontSize: 12, color: UIColor.appDefault.green, alignment: .center)
    let nameLabel: UILabel = .createTitle(text: "-", fontSize: 16, color: .black, alignment: .left)
    let connectionIconImage: UIImageView = .makeImageView("ConnectionStatusIcon")
    let connectionButton: UIButton = .createCustom(title: NSLocalizedString("Connect", comment: ""),
                                                   color: .clear, fontSize: 14,
                                                   textColor: UIColor.appDefault.green,
                                                   shadow: false, customContentEdgeInsets: false,
                                                   setCustomCornerRadius: false)
    
    let paramStack: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = .horizontal
        st.distribution = .equalSpacing
        return st
    }()
    let paramImages: [UIImageView] = {
        var p: [UIImageView] = []
        HeadersParamEnum.allCases.forEach { param in
            p.append(.makeImageView(param.rawValue))
        }
        return p
    }()
    let paramLabels: [UILabel] = {
        var p: [UILabel] = []
        HeadersParamEnum.allCases.forEach { param in
            p.append(.createTitle(text: "-"+param.label, fontSize: 14))
        }
        return p
    }()
    
    let watchIconImageHeight: CGFloat = 50
    let paramStackHeight: CGFloat = 16
    let contentInsetCustom: CGFloat = 24
    
    var device: ZHJBTDevice? {
        didSet {
            nameLabel.text = device?.name ?? "-"
            let tt = device == nil ? NSLocalizedString("Connect", comment: "") : NSLocalizedString("Connected", comment: "")
            connectionButton.setTitle(tt, for: .normal)
        }
    }
    
    var pow: Int? {
        didSet {
            guard let p = pow, p > 0 else { return }
            batteryPowerLabel.text = "\(p)%"
        }
    }
    
    var healthParams: [Float]? {
        didSet {
            guard let hParams = healthParams else { return }
            if let boIndex = HeadersParamEnum.bloodOxygen.index, let boParam = hParams[safe: boIndex], boParam > 0 {
                paramLabels[safe: boIndex]?.text = "\(boParam)" + HeadersParamEnum.bloodOxygen.label
            }
            if let tempIndex = HeadersParamEnum.temperature.index, let tempParam = hParams[safe: tempIndex], tempParam > 0 {
                paramLabels[safe: tempIndex]?.text = "\(tempParam)" + HeadersParamEnum.temperature.label
            }
            if let hrIndex = HeadersParamEnum.heartBeat.index, let hrParam = hParams[safe: hrIndex], hrParam > 0 {
                paramLabels[safe: hrIndex]?.text = "\(Int(hrParam))" + HeadersParamEnum.heartBeat.label
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubViews()
        setUpView()
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: "")
        setUpSubViews()
        setUpView()
    }
    
    func setHealthParams(bo: Float?, hr: Float?, temp: Float?) {
        var params: [Float] = []
        HeadersParamEnum.allCases.forEach { type in
            switch type {
            case .bloodOxygen:
                params.append(bo ?? 0)
            case .heartBeat:
                params.append(hr ?? 0)
            case .temperature:
                params.append(temp ?? 0)
            case .pressure:
                break
            }
        }
        healthParams = params
    }
    
    @objc func connectButtonTaped() {
        let devicesView = DevicesListModalView(frame: self.controller()?.view.frame ?? .zero)
        devicesView.show { _ in }
    }
    
    func setUpView() {
        self.backgroundColor = UIColor.appDefault.lightGrey
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = .white
        self.backgroundView?.setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: standartInset*1.5)
        self.backgroundView?.addCustomShadow()
    }
    
    func setUpSubViews() {
        contentView.addSubview(watchIconImage)
        contentView.addSubview(batteryPowerLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(connectionButton)
        contentView.addSubview(connectionIconImage)
        contentView.addSubview(paramStack)
        
        watchIconImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentInsetCustom).isActive = true
        watchIconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*1.5).isActive = true
        watchIconImage.heightAnchor.constraint(equalToConstant: watchIconImageHeight).isActive = true
        watchIconImage.widthAnchor.constraint(equalToConstant: watchIconImageHeight).isActive = true
        watchIconImage.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        
        batteryPowerLabel.topAnchor.constraint(equalTo: watchIconImage.topAnchor, constant: 0).isActive = true
        batteryPowerLabel.leadingAnchor.constraint(equalTo: watchIconImage.leadingAnchor, constant: 0).isActive = true
        batteryPowerLabel.trailingAnchor.constraint(equalTo: watchIconImage.trailingAnchor, constant: 0).isActive = true
        batteryPowerLabel.bottomAnchor.constraint(equalTo: watchIconImage.bottomAnchor, constant: 0).isActive = true
        batteryPowerLabel.adjustsFontSizeToFitWidth = true
        
        nameLabel.centerYAnchor.constraint(equalTo: watchIconImage.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: watchIconImage.trailingAnchor, constant: standartInset).isActive = true
        
        connectionIconImage.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        connectionIconImage.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: standartInset*1.5).isActive = true
        connectionIconImage.trailingAnchor.constraint(equalTo: connectionButton.leadingAnchor, constant: -standartInset/2).isActive = true
        connectionIconImage.heightAnchor.constraint(equalToConstant: standartInset).isActive = true
        let mult = standartInset * (connectionIconImage.image?.size.width ?? 1)/(connectionIconImage.image?.size.height ?? 1)
        connectionIconImage.widthAnchor.constraint(equalToConstant: mult).isActive = true
        connectionIconImage.tintColor = UIColor.appDefault.green
        connectionIconImage.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        connectionIconImage.setContentHuggingPriority(.init(1000), for: .vertical)
        
        connectionButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        connectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*1.5).isActive = true
        connectionButton.heightAnchor.constraint(equalToConstant: standartInset).isActive = true
        connectionButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        connectionButton.setContentHuggingPriority(.init(1000), for: .horizontal)
        connectionButton.addTarget(self, action: #selector(connectButtonTaped), for: .touchUpInside)
        
        paramStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*1.5).isActive = true
        paramStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*1.5).isActive = true
        paramStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentInsetCustom).isActive = true
        paramStack.heightAnchor.constraint(equalToConstant: paramStackHeight).isActive = true
        
        paramImages.enumerated().forEach { index, imgV in
            var vws: [UIView] = [imgV]
            if let lbl = paramLabels[safe: index] {
                vws.append(lbl)
            }
            let stk = UIStackView(arrangedSubviews: vws)
            stk.axis = .horizontal
            stk.spacing = standartInset/2
            let w = (imgV.image?.size.width ?? 1)/(imgV.image?.size.height ?? 1)
            imgV.widthAnchor.constraint(equalToConstant: paramStackHeight*w).isActive = true
            paramStack.addArrangedSubview(stk)
        }
    }
    
    static func getHeight() -> CGFloat {
        let cell = WatchHeaderTVCell()
        return cell.watchIconImageHeight + cell.paramStackHeight + cell.contentInsetCustom*3
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class WatchHeaderView: UIView {
    let watchIconImage: UIImageView = .makeImageView("watchHeaderIcon")
    let batteryPowerLabel: UILabel = .createTitle(text: "-%", fontSize: 12, color: UIColor.appDefault.green, alignment: .center)
    let nameLabel: UILabel = .createTitle(text: "-", fontSize: 16, weight: .bold, color: .black, alignment: .left)
    let connectionIconImage: UIImageView = .makeImageView("ConnectionStatusIcon")
    let connectionButton: UIButton = .createCustom(title: NSLocalizedString("Connect", comment: ""),
                                                   color: .clear, fontSize: 14,
                                                   textColor: UIColor.appDefault.green,
                                                   shadow: false, customContentEdgeInsets: false,
                                                   setCustomCornerRadius: false)
    let backgroundView: UIView = .createCustom()
    let contentView: UIView = .createCustom()
    
    let paramStack: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = .horizontal
        st.distribution = .equalSpacing
        return st
    }()
    let paramImages: [UIImageView] = {
        var p: [UIImageView] = []
        HeadersParamEnum.allCases.forEach { param in
            p.append(.makeImageView(param.rawValue))
        }
        return p
    }()
    let paramLabels: [UILabel] = {
        var p: [UILabel] = []
        HeadersParamEnum.allCases.forEach { param in
            p.append(.createTitle(text: "-"+param.label, fontSize: 14))
        }
        return p
    }()
    
    let watchIconImageHeight: CGFloat = 50
    let paramStackHeight: CGFloat = 32
    let contentInsetCustom: CGFloat = 24
    
    var device: ZHJBTDevice? {
        didSet {
            nameLabel.text = device?.name ?? "-"
            let tt = device == nil ? NSLocalizedString("Connect", comment: "") : NSLocalizedString("Connected", comment: "")
            connectionButton.setTitle(tt, for: .normal)
        }
    }
    
    var pow: Int? {
        didSet {
            guard let p = pow, p > 0 else { return }
            batteryPowerLabel.text = "\(p)%"
        }
    }
    
    var healthParams: [Float]? {
        didSet {
            guard let hParams = healthParams else { return }
            if let boIndex = HeadersParamEnum.bloodOxygen.index, let boParam = hParams[safe: boIndex], boParam > 0 {
                paramLabels[safe: boIndex]?.text = "\(boParam)" + HeadersParamEnum.bloodOxygen.label
            }
            if let tempIndex = HeadersParamEnum.temperature.index, let tempParam = hParams[safe: tempIndex], tempParam > 0 {
                paramLabels[safe: tempIndex]?.text = "\(tempParam)" + HeadersParamEnum.temperature.label
            }
            if let hrIndex = HeadersParamEnum.heartBeat.index, let hrParam = hParams[safe: hrIndex], hrParam > 0 {
                paramLabels[safe: hrIndex]?.text = "\(Int(hrParam))" + HeadersParamEnum.heartBeat.label
            }
        }
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setUpSubViews()
//        setUpView()
//    }
    
    init() {
        //super.init(style: .default, reuseIdentifier: "")
        super.init(frame: .zero)
        setUpSubViews()
        setUpView()
    }
    
    func setHealthParams(bo: Float?, hr: Float?, temp: Float?) {
        var params: [Float] = []
        HeadersParamEnum.allCases.forEach { type in
            switch type {
            case .bloodOxygen:
                params.append(bo ?? 0)
            case .heartBeat:
                params.append(hr ?? 0)
            case .temperature:
                params.append(temp ?? 0)
            case .pressure:
                break
            }
        }
        healthParams = params
    }
    
    @objc func connectButtonTaped() {
        let devicesView = DevicesListModalView(frame: self.controller()?.view.frame ?? .zero)
        devicesView.show { _ in }
    }
    
    func setUpView() {
        self.addSubview(backgroundView)
        self.addSubview(contentView)
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.bringSubviewToFront(contentView)
        
        self.backgroundColor = UIColor.appDefault.lightGrey
        self.backgroundView.backgroundColor = .white
        self.backgroundView.setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: standartInset*1.5)
        self.backgroundView.addCustomShadow()
    }
    
    func setUpSubViews() {
        contentView.addSubview(watchIconImage)
        contentView.addSubview(batteryPowerLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(connectionButton)
        contentView.addSubview(connectionIconImage)
        contentView.addSubview(paramStack)
        
        watchIconImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentInsetCustom).isActive = true
        watchIconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*1.5).isActive = true
        watchIconImage.heightAnchor.constraint(equalToConstant: watchIconImageHeight).isActive = true
        watchIconImage.widthAnchor.constraint(equalToConstant: watchIconImageHeight).isActive = true
        watchIconImage.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        
        batteryPowerLabel.topAnchor.constraint(equalTo: watchIconImage.topAnchor, constant: 0).isActive = true
        batteryPowerLabel.leadingAnchor.constraint(equalTo: watchIconImage.leadingAnchor, constant: 0).isActive = true
        batteryPowerLabel.trailingAnchor.constraint(equalTo: watchIconImage.trailingAnchor, constant: 0).isActive = true
        batteryPowerLabel.bottomAnchor.constraint(equalTo: watchIconImage.bottomAnchor, constant: 0).isActive = true
        batteryPowerLabel.adjustsFontSizeToFitWidth = true
        
        nameLabel.centerYAnchor.constraint(equalTo: watchIconImage.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: watchIconImage.trailingAnchor, constant: standartInset).isActive = true
        
        connectionIconImage.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        connectionIconImage.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: standartInset*1.5).isActive = true
        connectionIconImage.trailingAnchor.constraint(equalTo: connectionButton.leadingAnchor, constant: -standartInset/2).isActive = true
        connectionIconImage.heightAnchor.constraint(equalToConstant: standartInset).isActive = true
        let mult = standartInset * (connectionIconImage.image?.size.width ?? 1)/(connectionIconImage.image?.size.height ?? 1)
        connectionIconImage.widthAnchor.constraint(equalToConstant: mult).isActive = true
        connectionIconImage.tintColor = UIColor.appDefault.green
        connectionIconImage.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        connectionIconImage.setContentHuggingPriority(.init(1000), for: .vertical)
        
        connectionButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        connectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*1.5).isActive = true
        connectionButton.heightAnchor.constraint(equalToConstant: standartInset).isActive = true
        connectionButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        connectionButton.setContentHuggingPriority(.init(1000), for: .horizontal)
        connectionButton.addTarget(self, action: #selector(connectButtonTaped), for: .touchUpInside)
        
        paramStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*1.5).isActive = true
        paramStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*1.5).isActive = true
        paramStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentInsetCustom).isActive = true
        paramStack.heightAnchor.constraint(equalToConstant: paramStackHeight).isActive = true
        
        paramImages.enumerated().forEach { index, imgV in
            var vws: [UIView] = [imgV]
            if let lbl = paramLabels[safe: index] {
                vws.append(lbl)
            }
            let stk = UIStackView(arrangedSubviews: vws)
            stk.axis = .horizontal
            stk.spacing = standartInset/2
            let w = (imgV.image?.size.width ?? 1)/(imgV.image?.size.height ?? 1)
            imgV.widthAnchor.constraint(equalToConstant: paramStackHeight*w).isActive = true
            paramStack.addArrangedSubview(stk)
        }
    }
    
    static func getHeight() -> CGFloat {
        let cell = WatchHeaderTVCell()
        return cell.watchIconImageHeight + cell.paramStackHeight + cell.contentInsetCustom*3
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
