//
//  WatchManagerDelegate.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 03.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import TrusangBluetooth

protocol TrusangDeviceDelegate {
    func deviceConnected(device: ZHJBTDevice?, success: Bool)
    func batteryPowerUpdated(_ pow: Int)
    func deviceDisconnected()
}

@objc protocol WatchListDelegate {
    func deviceConnected(device: ZHJBTDevice, success: Bool)
    func deviceDisconnected()
}

@objc protocol WatchReadParamsDelegate {
    @objc optional func didStartConnecting()
    func didConnected(_ device: ZHJBTDevice?, success: Bool)
    func deviceDisconnected()
    
    @objc optional func batteryPowerUpdated(_ pow: Int)
    
    func syncDidStart()
    @objc optional func syncDidUpdate()
    func syncDidEnd()
    
    func parametersDidUpdate()
}
