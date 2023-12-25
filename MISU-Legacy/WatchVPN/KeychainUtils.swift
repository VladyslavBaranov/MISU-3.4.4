//
//  KeychainUtils.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 10/10/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

struct MainKeys {
    static let mainUserToken = "mainUserToken42"
    static let userDeviceName = "userDeviceName42"
    static let userDeviceUpdateTime = "userDeviceUpdateTime42"
}

class KeychainUtils {
    static let shared = KeychainWrapper(serviceName: "MISU", accessGroup: "72WUHGD9M7.com.WH.MISU")
    
    static func getSharedDeviceName() -> String? {
        if let name = shared.string(forKey: MainKeys.userDeviceName) {
            return name
        }
        return nil
    }
    
    static func getSharedCurrentUserToken() -> String? {
        if let token = shared.string(forKey: MainKeys.mainUserToken) {
            return token
        }
        return nil
    }
    
    static func getSharedDeviceUpdateTime() -> Int? {
        return shared.integer(forKey: MainKeys.userDeviceUpdateTime)
    }
}

