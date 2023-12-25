//
//  AuthenticationModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 29.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct AuthenticationModel {
    var credentials: String = ""
    var pinToken: String = ""
    var token: String = ""
    var isNumber: Bool = false
    var isRegistration: Bool = false
    var detail: String = ""
    
    var firebaseVerificationID: String = ""
    var firebaseUid: String = ""
    
    let userDefaultKey: String = "WaitingForPin_^kjandkj&@%#jha&Y"
    
    init(cred: String = "", isReg: Bool = false) {
        self.credentials = cred
    }
    
    init(token tk: String = "") {
        self.token = tk
    }
    
    mutating func logIn(cred: String) {
        fillFields(cred: cred)
        isRegistration = false
    }
    
    mutating func registration(cred: String) {
        fillFields(cred: cred)
        isRegistration = true
    }
    
    mutating private func fillFields(cred: String) {
        credentials = cred.lowercased()
        isNumber = true
    }
    
    func getInfoLabelText() -> String {
        if isNumber {
            return NSLocalizedString("Verification code has been sent to your number", comment: "")
        }
        return NSLocalizedString("Verification code has been sent to your inbox", comment: "")
    }
    
    mutating func wasNumberToWaitSMS() -> Bool {
        AuthManager
        guard getFromUserDef() else { return false }
        if !credentials.isEmpty {
            isRegistration = false
            isNumber = true
            return true
        }
        return false
    }
    
    func waitingForSMS() {
        saveToUserDef()
    }
    
    func gotSMS() {
        UserDefaultsUtils.removeBy(key: userDefaultKey)
    }
    
    func saveToUserDef() {
        _ = UserDefaultsUtils.saveModel(value: self, key: userDefaultKey)
    }
    
    func clearUserDef() {
        UserDefaultsUtils.removeBy(key: userDefaultKey)
    }
    
    mutating func getFromUserDef() -> Bool{
        guard let old = UserDefaultsUtils.getModel(type: AuthenticationModel.self, key: userDefaultKey) else { return false }
        if !credentials.isEmpty, credentials == old.credentials {
            self = old
            return true
        } else if !credentials.isEmpty {
            return false
        } else {
            self = old
            return true
        }
    }
}



// MARK: - Codable
extension AuthenticationModel: Codable {
    enum Keys: String, CodingKey {
        case email = "email"
        case mobile = "mobile"
        case detail = "detail"
        case pinToken = "token"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        detail = (try? container.decode(String.self, forKey: .detail)) ?? ""
        token = (try? container.decode(String.self, forKey: .pinToken)) ?? ""
        credentials = (try? container.decode(String.self, forKey: .mobile)) ?? ""
        token = (try? container.decode(String.self, forKey: .pinToken)) ?? ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(credentials, forKey: .mobile)
    }
    
    public func getParamForRegistrationRequest() -> Parameters {
        return isNumber ? [Keys.mobile.rawValue:credentials] : [Keys.email.rawValue:credentials]
    }
    
    public func getParamForLoginRequest() -> Parameters {
        return isNumber ? [Keys.mobile.rawValue:credentials, Keys.pinToken.rawValue:firebaseUid] : [Keys.email.rawValue:credentials, Keys.pinToken.rawValue:pinToken]
    }
}

