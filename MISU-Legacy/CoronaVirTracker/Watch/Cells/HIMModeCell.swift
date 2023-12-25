//
//  HIMModeCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 04.12.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class HIMModeCell: CustomTVCell {
    let mainView: UIView = .createCustom()
    let onOfSwitch: UISwitch = .create()
    override var mainStackEdgeInset: UIEdgeInsets {
        .init(top: Constants.inset, left: Constants.inset, bottom: Constants.inset, right: Constants.inset)
    }
    
    override func setUp() {
        //super.setUp()
        backgroundColor = .clear
        contentView.addSubview(mainView)
        mainView.fixedEdgesConstraints(on: contentView, inset: .init(top: 0, left: Constants.inset/2, bottom: 0, right: Constants.inset/2))
        mainView.cornerRadius = Constants.cornerRadius
        mainView.backgroundColor = .white
        mainView.addCustomShadow()
        
        titleLabel.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(100), for: .horizontal)
        titleLabel.font = .systemFont(ofSize: 14)
        
        mainStack.distribution = .fill
        mainView.addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: mainView, inset: mainStackEdgeInset)
        
        titleLabel.text =  NSLocalizedString("Health Intensive Monitoring", comment: "")
        
        //iconImage.removeFromSuperview()
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(onOfSwitch)
        onOfSwitch.addTarget(self, action: #selector(onOfSwitchSwitched(_:)), for: .valueChanged)
    }
}


extension HIMModeCell {
    @IBAction func onOfSwitchSwitched(_ sender: UISwitch) {
        if sender.isOn {
            let vc = StartHIMModeVC { start in
                self.switchSwitcher(isOn: start)
            }
            controller()?.present(vc, animated: true)
        } else {
            WatchFakeVPNManager.shared.stopVPN()
            WatchFakeVPNManager.shared.removeVPNFromPrefs()
        }
    }
    
    func switchSwitcher(isOn: Bool) {
        DispatchQueue.main.async {
            self.onOfSwitch.setOn(isOn, animated: true)
        }
    }

    func checkStatus() {
        WatchFakeVPNManager.shared.loadFromPrefs { _, _ in
            DispatchQueue.main.async {
                self.onOfSwitch.setOn(
                    WatchFakeVPNManager.shared.manager?.connection.status == .connected,
                    animated: true
                )
            }
        }
    }
    
    static func getHeight() -> CGFloat {
        let cell = self.init()
        return cell.mainStackEdgeInset.top + cell.mainStackEdgeInset.bottom + cell.onOfSwitch.bounds.height
    }
}
