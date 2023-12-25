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
    
    //-------------------------------------------------------------------------------------------
    // MARK: - shared Keychain
    //-------------------------------------------------------------------------------------------
    
    static let shared = KeychainWrapper(serviceName: "MISU", accessGroup: "72WUHGD9M7.com.WH.MISU")
    
    static func saveToSharedCurrentUserToken(_ token: String) -> Bool {
        return shared.set(token, forKey: MainKeys.mainUserToken)
    }
    static func getSharedCurrentUserToken() -> String? {
        return shared.string(forKey: MainKeys.mainUserToken)
    }
    
    static func saveToSharedDeviceName(_ name: String) -> Bool {
        return shared.set(name, forKey: MainKeys.userDeviceName)
    }
    static func getSharedDeviceName() -> String? {
        return shared.string(forKey: MainKeys.userDeviceName)
    }
    
    static func saveToSharedDeviceUpdateTime(_ time: Int) -> Bool {
        return shared.set(time, forKey: MainKeys.userDeviceUpdateTime)
    }
    static func getSharedDeviceUpdateTime() -> Int? {
        return shared.integer(forKey: MainKeys.userDeviceUpdateTime)
    }
    //-------------------------------------------------------------------------------------------
    // MARK: - save to SwiftKeychainWrapper
    //-------------------------------------------------------------------------------------------
    
    static func saveCurrentUserToken(_ token: String) -> Bool {
        return KeychainWrapper.standard.set(token, forKey: MainKeys.mainUserToken)
    }
    
    static func saveInt(value: Int, key: String) -> Bool {
        return KeychainWrapper.standard.set(value, forKey: key)
    }
    
    static func saveString(value: String, key: String) -> Bool {
        return KeychainWrapper.standard.set(value, forKey: key)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - get from SwiftKeychainWrapper
    //-------------------------------------------------------------------------------------------
    
    static func getCurrentUserToken() -> String? {
        
        if !(UserDefaultsUtils.getBool(key: MainKeys.mainUserToken) ?? false) {
            UserDefaultsUtils.save(value: true, key: MainKeys.mainUserToken)
            _ = KeychainUtils.removeAll()
            return nil
        }
        
        if let token = KeychainWrapper.standard.string(forKey: MainKeys.mainUserToken) {
            return token
        }
        return nil
    }
    
    static func getBy<T>(key: String, type: T.Type) -> (value: T?, error: String?) {
        switch T.self {
        case is String.Type:
            if let value = KeychainWrapper.standard.string(forKey: key) as? T {
                return (value, nil)
            }
        case is Int.Type:
            if let value = KeychainWrapper.standard.integer(forKey: key) as? T {
                return (value, nil)
            }
        case is Bool.Type:
            if let value = KeychainWrapper.standard.bool(forKey: key) as? T {
                return (value, nil)
            }
        case is Data.Type:
            if let value = KeychainWrapper.standard.data(forKey: key) as? T {
                return (value, nil)
            }
        case is Double.Type:
            if let value = KeychainWrapper.standard.double(forKey: key) as? T {
                return (value, nil)
            }
        default:
            return(nil, KeychainErrorHandler.typeNotHandled.rawValue)
        }
        
        return(nil, KeychainErrorHandler.valueNil.rawValue)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - remove from SwiftKeychainWrapper
    //-------------------------------------------------------------------------------------------
    
    static func removeCurrentUserToken() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: MainKeys.mainUserToken)
    }
    
    static func remove(key: String) -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: key)
    }
    
    static func removeAll() -> Bool {
        return KeychainWrapper.standard.removeAllKeys()
    }
}

public enum KeychainErrorHandler: String, Error {
    case tokenNotFound = "Token was not found ..."
    case valueNil = "Value was not found ..."
    case typeNotHandled = "Return type is not handled ..."
}
