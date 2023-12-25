//
//  WatchHeaderHIMMTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 27.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class WatchHeaderHIMMTVCell: UITableViewCell {
    let mainStack: UIStackView = .createCustom(alignment: .top)
    let devicesListStack: UIStackView = .createCustom(axis: .vertical, spacing: Constants.inset24, alignment: .leading)
    let rightButtonsStack: UIStackView = .createCustom(axis: .vertical, spacing: Constants.inset, alignment: .leading)
    
    var mainStackEdgesInsets: UIEdgeInsets = .init(const: Constants.inset)
    
    var devicesList: [DeviceView] = WatchesController.shared.connectedDevices.map { return $0.view }
    
    let updateDataButton: CoolButton = CoolButton(title: NSLocalizedString("Update data", comment: ""),
                                                  fontSize: 12, textColor: .white, color: .appDefault.green)

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
    
    func updateDevices() {
        devicesList.forEach { $0.removeFromSuperview() }
        devicesList = WatchesController.shared.connectedDevices.map { return $0.view }
        devicesList.forEach { value in
            value.startUpdating()
            devicesListStack.addArrangedSubview(value)
        }
        
        if devicesList.count > 1 {
            mainStack.alignment = .top
        } else {
            mainStack.alignment = .center
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        startUpdateAllDevices()
    }

    @objc func connectButtonTaped() {
        let devicesView = DevicesListModalView(frame: self.controller()?.view.frame ?? .zero)
        devicesView.show { _ in
            if WatchesController.shared.wasConnectedAny {
                self.navigationController()?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func reloadButtonAction(_ sender: UIButton) {
        // FIX reloadin button process. updating, process
        // sender.imageView?.animateRotate(duration: 5)
        WatchesController.shared.updateAllData()
        startUpdateAllDevices()
        HealthDataController.shared.updateAllData()
    }
    
    func startUpdateAllDevices() {
        devicesList.forEach { device in
            device.startUpdating()
        }
    }
    
    func setUpView() {
        self.backgroundColor = UIColor.appDefault.lightGrey
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = .white
        self.backgroundView?.setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: standartInset*1.5)
        self.backgroundView?.addCustomShadow()
    }

    func setUpSubViews() {
        contentView.addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: contentView, inset: mainStackEdgesInsets)
        
        mainStack.addArrangedSubview(devicesListStack)
        mainStack.addArrangedSubview(rightButtonsStack)
        
        updateDevices()
        
        updateDataButton.heightAnchor.constraint(equalToConstant: DeviceType.basetHeight).isActive = true
        updateDataButton.addTarget(self, action: #selector(reloadButtonAction(_:)), for: .touchUpInside)
        
        rightButtonsStack.addArrangedSubview(updateDataButton)
        rightButtonsStack.setContentHuggingPriority(.init(1000), for: .horizontal)
        rightButtonsStack.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
    }

    static func getHeight() -> CGFloat {
        let cell = WatchHeaderHIMMTVCell()
        
        var cd = WatchesController.shared.connectedDevices.reduce(into: CGFloat()) { partialResult, device in
            partialResult += device.defaultHeight
        }
        
        if WatchesController.shared.connectedDevices.count > 0 {
            cd += CGFloat(WatchesController.shared.connectedDevices.count - 1) * cell.devicesListStack.spacing
        }
        
        if cd < DeviceType.basetHeight {
            cd = DeviceType.basetHeight
        }
        
        return cell.mainStackEdgesInsets.top + cell.mainStackEdgesInsets.bottom + cd
    }
    
    required init?(coder: NSCoder) {
        super.init(style: .default, reuseIdentifier: "")
        setUpSubViews()
        setUpView()
    }
}
