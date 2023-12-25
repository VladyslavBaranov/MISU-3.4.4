//
//  WatchesController.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 21.10.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

protocol WatchesControllerDelegate {
    func deviceConnected()
    func deviceDisconnected()
}

class WatchesController {
    static let shared = WatchesController()
    private init() {}
    
    let trusangManager = DeviceType.TrusangZHJBT.manager
    let appleManager = DeviceType.AppleHK.manager
    
    var delegate: WatchesControllerDelegate?
    
    var wasConnectedAny: Bool {
        return trusangManager.isConnected || appleManager.isConnected
    }
    
    var connectedDevices: [DeviceType] {
        return DeviceType.allCases.reduce(into: [DeviceType]()) { result, device in
            if device.manager.isConnected {
                result.append(device)
            }
        }
    }
}

extension WatchesController {
    func updateAllData() {
        DeviceType.allCases.forEach { $0.manager.updateAllData() }
    }
}





