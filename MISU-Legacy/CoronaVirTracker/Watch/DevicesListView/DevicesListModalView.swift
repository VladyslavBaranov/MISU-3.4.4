//
//  DevicesListModalView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import TrusangBluetooth

class DevicesListModalView: BaseEditView {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Add device", comment: "") , fontSize: 18, color: .black, alignment: .center)
    let reloadButton: UIButton = .createCustom(withImage: UIImage(named: "reloadIcon"), backgroundColor: .clear, contentEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), imageRenderingMode: .alwaysOriginal, cornerRadius: 0, shadow: false)
    let devicesTableView: UITableView = .createTableView()
    let cellId = "cellId"
    let cellIdUn = "cellIdUn"
    
    let infoReloadStack: UIStackView = .createCustom()
    let infoContainerStack = UIStackView.createCustom(axis: .vertical)
    let firstInfoLabel: UILabel = .createTitle(text: NSLocalizedString("Tap", comment: ""), fontSize: 16, color: .gray)
    let imageInfo: UIImageView = .makeImageView(UIImage(named: "reloadIcon")?.scaleTo(24), withRenderingMode: .alwaysTemplate, tintColor: .gray)
    let secondInfoLabel: UILabel = .createTitle(text: NSLocalizedString("to reload", comment: ""), fontSize: 16, color: .gray)
    let connectInfoLabel: UILabel = .createTitle(text: NSLocalizedString("Make sure the MISU Watch is not connected to other devices", comment: ""), fontSize: 16, color: .gray, alignment: .center)
    
    let wManager = WatchSinglManager.shared
    var devices: [ZHJBTDevice] = []
    let scanDevicesSeconds: TimeInterval = 3.0
    
    override func setUp() {
        super.setUp()
        dataSetUp()
        setUpTableView()
        saveButton.removeFromSuperview()
        wManager.listDelegate = self
    }
}



// MARK: - WatchManagerDelegate
extension DevicesListModalView: WatchListDelegate {
    func deviceDisconnected() {
        DispatchQueue.main.async {
            self.devicesTableView.reloadData()
        }
    }
    
    func deviceConnected(device: ZHJBTDevice, success: Bool) {
        guard success else { return }
        device.isConnected = true
        if let cellId = devices.firstIndex(where: { $0 == device }) {
            devicesTableView.reloadRows(at: [IndexPath(row: cellId, section: 0)], with: .fade)
        } else {
            devicesTableView.reloadData()
        }
        cancelButtonAction()
    }
}



// MARK: - TableView Delegate, DataSource
extension DevicesListModalView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DeviceType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DeviceType(rawValue: section) {
        case .AppleHK:
            return 1
        case .TrusangZHJBT:
            return devices.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DeviceTVCell {
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: cellIdUn, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch DeviceType(rawValue: indexPath.section) {
        case .AppleHK:
            (cell as? DeviceTVCell)?.apple = true
        case .TrusangZHJBT:
            (cell as? DeviceTVCell)?.device = devices[safe: indexPath.row]
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



// MARK: - Additional views set up
extension DevicesListModalView {
    @objc private func dataSetUp() {
        reloadButton.animateRotate(duration: scanDevicesSeconds)
        self.reloadButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDevicesSeconds) {
            self.reloadButton.isEnabled = true
        }
        
        wManager.scanDevices(seconds: scanDevicesSeconds) { [self] (dvcs) in
            devices = dvcs
            devicesTableView.reloadData()
            contentView.layoutIfNeeded()
            devicesTableView.animateConstraint(devicesTableView.customHeightAnchorConstraint, constant: devicesTableView.contentSize.height + standart24Inset, duration: 0.1)
        }
    }
    
    private func setUpTableView() {
        let titleView: UIView = .createCustom()
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(reloadButton)
        contentView.addSubview(infoContainerStack)
        
        titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: standartInset*2).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -standartInset*2).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        reloadButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        reloadButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -standartInset*2).isActive = true
        reloadButton.widthAnchor.constraint(equalToConstant: reloadButton.minWidth).isActive = true
        reloadButton.heightAnchor.constraint(equalToConstant: reloadButton.minHeight).isActive = true
        reloadButton.addTarget(self, action: #selector(dataSetUp), for: .touchUpInside)
        
        infoContainerStack.addArrangedSubview(titleView)
        titleView.widthAnchor.constraint(equalTo: infoContainerStack.widthAnchor).isActive = true
        infoContainerStack.addArrangedSubview(devicesTableView)
        
        if UCardSingleManager.shared.user.number == "+380987680603" {
            reloadButton.setImage(UIImage(named: "koliaReloadIcon"), for: .normal)
            reloadButton.imageView?.contentMode = .scaleAspectFill
            reloadButton.imageView?.clipsToBounds = false
        }
        
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.cornerRadius = 10
        let cell = DeviceTVCell(style: .default, reuseIdentifier: "")
        cell.layoutIfNeeded()
        let oneRowHeight = cell.connectButton.frame.height + standartInset
        devicesTableView.rowHeight = oneRowHeight
        devicesTableView.separatorColor = .clear
        //devicesTableView.alwaysBounceVertical = false
        
        devicesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdUn)
        devicesTableView.register(DeviceTVCell.self, forCellReuseIdentifier: cellId)
        
        // devicesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset*4).isActive = true
        devicesTableView.leadingAnchor.constraint(equalTo: infoContainerStack.leadingAnchor).isActive = true
        devicesTableView.trailingAnchor.constraint(equalTo: infoContainerStack.trailingAnchor).isActive = true
        devicesTableView.customHeightAnchorConstraint = devicesTableView.heightAnchor.constraint(equalToConstant: oneRowHeight)
        devicesTableView.customHeightAnchorConstraint?.isActive = true
        // devicesTableView.bottomAnchor.constraint(equalTo: infoContainerStack.topAnchor, constant: -standartInset*4).isActive = true
        
        infoContainerStack.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        infoContainerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        infoContainerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        infoContainerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        infoContainerStack.addArrangedSubview(infoReloadStack)
        infoContainerStack.addArrangedSubview(connectInfoLabel)
        infoReloadStack.addArrangedSubview(firstInfoLabel)
        infoReloadStack.addArrangedSubview(imageInfo)
        infoReloadStack.addArrangedSubview(secondInfoLabel)
        connectInfoLabel.numberOfLines = 5
        connectInfoLabel.widthAnchor.constraint(equalTo: infoContainerStack.widthAnchor, multiplier: 0.9).isActive = true
        
        imageInfo.addTapRecognizer(self, action: #selector(dataSetUp))
    }
}

