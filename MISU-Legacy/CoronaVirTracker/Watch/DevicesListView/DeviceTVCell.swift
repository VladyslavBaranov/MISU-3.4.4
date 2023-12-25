//
//  DeviceTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import TrusangBluetooth

class DeviceTVCell: UITableViewCell, RequestUIController, HealthKitConnectionDelegate {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    let nameTitle: UILabel = .createTitle(text: "-", fontSize: 16, color: .black, alignment: .left)
    let connectButton: UIButton = .createCustom(title: NSLocalizedString("Connect", comment: ""), color: UIColor.appDefault.bluePrimary, fontSize: 14, textColor: .white, shadow: false, customContentEdgeInsets: true)
    
    var device: ZHJBTDevice? {
        didSet {
            updateInfo()
        }
    }
    
    var apple: Bool = false {
        didSet {
            if !apple { return }
            HealthKitAssistant.shared.connectDelegate = self
            nameTitle.text = "Apple Watch (Health Kit)"
            updateButton(
                connected: HealthKitAssistant.shared.isConnected
            )
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        apple = false
        device = nil
        
        enableViewsAfterReqest()
        updateInfo()
    }
    
    @objc func connectButtonAction() {
        if apple {
            connectApple()
            return
        }
        guard let dv = device else { return }
        prepareViewsBeforReqest(viewsToBlock: [], activityButton: connectButton)
        if dv.peripheral?.identifier == WatchSinglManager.shared.connectedDeviceCB?.identifier {
            WatchSinglManager.shared.disconnectDeviceFully()
            return
        }
        WatchSinglManager.shared.connectDevice(dv) { success in
            self.enableViewsAfterReqest()
        }
    }
    
    func connectApple() {
        HealthKitAssistant.shared.connectDisconnectActions()
    }
    
    func beginHKConnecting() {
        prepareViewsBeforReqest(viewsToBlock: [], activityButton: connectButton)
    }
    
    func endHKConnecting() {
        enableViewsAfterReqest()
        DispatchQueue.main.async {
            self.updateButton(connected: HealthKitAssistant.shared.isConnected)
        }
    }
    
    func updateInfo() {
        nameTitle.text = device?.name ?? "-"
        
        print(device?.peripheral?.identifier == WatchSinglManager.shared.connectedDeviceCB?.identifier)
        updateButton(
            connected: device?.peripheral?.identifier == WatchSinglManager.shared.connectedDeviceCB?.identifier
        )
    }
    
    func updateButton(connected: Bool) {
        if connected {
            connectButton.setTitle(NSLocalizedString("Disconnect", comment: ""), for: .normal)
            connectButton.originText = NSLocalizedString("Disconnect", comment: "")
            connectButton.setTitleColor(.white, for: .normal)
            connectButton.backgroundColor = .lightGray
        } else {
            connectButton.setTitle(NSLocalizedString("Connect", comment: ""), for: .normal)
            connectButton.originText = NSLocalizedString("Connect", comment: "")
            connectButton.backgroundColor = UIColor.appDefault.bluePrimary
        }
    }

    func setUpSubViews() {
        contentView.addSubview(nameTitle)
        contentView.addSubview(connectButton)
        
        nameTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        nameTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        connectButton.setContentHuggingPriority(.init(1000), for: .horizontal)
        connectButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        connectButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        connectButton.leadingAnchor.constraint(equalTo: nameTitle.trailingAnchor, constant: standartInset).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        connectButton.addTarget(self, action: #selector(connectButtonAction), for: .touchUpInside)
    }
}
