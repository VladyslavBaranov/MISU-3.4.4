//
//  WatchHIMModTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 01.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit
import NetworkExtension

class WatchHIMModTVCell: UITableViewCell {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Health Intensive Monitoring", comment: ""), fontSize: 16, color: .darkGray)
    let onOfSwitch: UISwitch = .create()
    var observer: NSObjectProtocol? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubViews()
        setUpView()
        
        //WatchFakeVPNManager.shared.delegate = self
        checkStatus()
        //onOfSwitch.setOn(true, animated: true)
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: "")
        setUpSubViews()
        setUpView()
        
        //WatchFakeVPNManager.shared.delegate = self
        //WatchFakeVPNManager.shared.loadFromPrefs()
    }
    
    @objc func onOfSwitchSwitched(sender: UISwitch) {
        //print("### onOfSwitchSwitched \(sender.isOn)")
        if sender.isOn {
            let vc = StartHIMModeVC { start in
                self.switchSwitder(isOn: start)
            }
            controller()?.present(vc, animated: true)
        } else {
            WatchFakeVPNManager.shared.stopVPN()
            WatchFakeVPNManager.shared.removeVPNFromPrefs()
        }
    }
    
    func switchSwitder(isOn: Bool) {
        DispatchQueue.main.async {
            self.onOfSwitch.setOn(isOn, animated: true)
        }
    }
    
    func checkStatus() {
        WatchFakeVPNManager.shared.loadFromPrefs { _, _ in
            DispatchQueue.main.async {
                self.onOfSwitch.setOn(WatchFakeVPNManager.shared.manager?.connection.status == .connected, animated: true)
            }
        }
    }
    
    func setUpView() {
        backgroundColor = .clear
        contentView.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
    
    func setUpSubViews() {
        //accessoryType = .detailButton
        
        contentView.addSubview(onOfSwitch)
        contentView.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: onOfSwitch.leadingAnchor, constant: -standartInset).isActive = true
        
        onOfSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        onOfSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        onOfSwitch.addTarget(self, action: #selector(onOfSwitchSwitched(sender:)), for: .valueChanged)
    }
    
    static func getHeight() -> CGFloat {
        let cell = WatchHIMModTVCell()
        return cell.onOfSwitch.frame.height + cell.standart24Inset
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkStatus()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //WatchFakeVPNManager.shared.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
