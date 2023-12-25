//
//  DeviceViews.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 09.12.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit
import TrusangBluetooth

class DeviceView: UIView {
    let mainStack: UIStackView = .createCustom(spacing: Constants.inset/2)
    let iconImage: UIImageView = .makeImageView(UIImage(named: "watchHeaderIcon"))
    let nameLabel: UILabel = .createTitle(text: "-", fontSize: 10, color: .black, alignment: .left)
    
    let updatingStatusImage: UIImageView = .makeImageView(UIImage(named: "reloadIcon"))
    let customRotatingDuration: Double = 3.0
    
    var deviceType: DeviceType?
    
    var mainStackInsets: UIEdgeInsets = .init(const: 0) {
        didSet {
            mainStack.removeFromSuperview()
            self.addSubview(mainStack)
            mainStack.fixedEdgesConstraints(on: self, inset: mainStackInsets)
        }
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    func setUp() {
        translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: self, inset: mainStackInsets)
        
        mainStack.addArrangedSubview(iconImage)
        mainStack.addArrangedSubview(nameLabel)
        //mainStack.addArrangedSubview(updatingStatusImage)
        
        nameLabel.setContentHuggingPriority(.init(1001), for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        
        iconImage.heightAnchor.constraint(equalToConstant: DeviceType.AppleHK.defaultHeight).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: DeviceType.TrusangZHJBT.defaultHeight).isActive = true
        updatingStatusImage.heightAnchor.constraint(equalToConstant: Constants.inset).isActive = true
        updatingStatusImage.widthAnchor.constraint(equalToConstant: Constants.inset).isActive = true
    }
    
    func startUpdating() {
        if self.deviceType?.manager.isUpdating != true { return }
        mainStack.addArrangedSubview(updatingStatusImage)
        rotateUpdatingImage {
            self.updatingStatusImage.removeFromSuperview()
        }
    }
    
    func rotateUpdatingImage(_ completion: @escaping ()->Void) {
        updatingStatusImage.animateRotate(duration: customRotatingDuration) {
            if self.deviceType?.manager.isUpdating == true {
                self.rotateUpdatingImage(completion)
            } else {
                completion()
            }
        }
    }
}



class MISUWatchV1View: DeviceView, TrusangDeviceDelegate {
    let batteryPowerLabel: UILabel = .createTitle(text: "-%", fontSize: 12, color: UIColor.appDefault.green, alignment: .center)
    
    var device: ZHJBTDevice? {
        didSet {
            nameLabel.text = device?.name ?? "MISU Watch"
        }
    }
    
    var pow: Int? {
        didSet {
            guard let p = pow, p > 0 else { return }
            if p > 100 {
                batteryPowerLabel.text = ""
                iconImage.image = UIImage(named: "watchChargingIcon")
            } else {
                batteryPowerLabel.text = "\(p)%"
                iconImage.image = UIImage(named: "watchHeaderIcon")
            }
        }
    }
    
    func deviceConnected(device: ZHJBTDevice?, success: Bool) {
        self.device = device
    }
    
    func deviceDisconnected() {
        device = nil
    }
    
    func batteryPowerUpdated(_ pow: Int) {
        self.pow = pow
    }
    
    override func setUp() {
        super.setUp()
        nameLabel.text = "MISU Watch"
        nameLabel.font = .systemFont(ofSize: 16)
        
        iconImage.addSubview(batteryPowerLabel)
        
        batteryPowerLabel.topAnchor.constraint(equalTo: iconImage.topAnchor, constant: 0).isActive = true
        batteryPowerLabel.leadingAnchor.constraint(equalTo: iconImage.leadingAnchor, constant: 0).isActive = true
        batteryPowerLabel.trailingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 0).isActive = true
        batteryPowerLabel.bottomAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 0).isActive = true
        batteryPowerLabel.adjustsFontSizeToFitWidth = true
        
        iconImage.customHeightAnchorConstraint?.constant = DeviceType.TrusangZHJBT.defaultHeight
        
        WatchSinglManager.shared.trusangDeviceDelegate = self
        pow = WatchSinglManager.shared.devicePow
        device = WatchSinglManager.shared.connectedDeviceZHJ
    }
}
