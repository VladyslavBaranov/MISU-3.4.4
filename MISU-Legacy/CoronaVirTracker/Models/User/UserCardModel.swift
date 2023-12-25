//
//  UserCardModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/12/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

struct UserModel {
    let id: Int
    var username: String?
    var email: String?
    var number: String?
    var profile: UserCardModel?
    var doctor: DoctorModel?
    var location: LocationModel?
    var isDoctor: Bool = false
    var userType: UserTypeEnum? = nil
    
    var isCurrent: Bool = false
    
    init(id: Int) {
        self.id = id
    }
}

extension UserModel {
    func saveToUserDef(key: String = Keys.mainUserDef.rawValue) {
        if !UserDefaultsUtils.saveModel(value: self, key: key) {
            BeautifulOutputer.cPrint(type: .warning, place: .medicalID, message1: "not saved to user def", message2: String(describing: self))
        }
    }
    
    mutating func getFromUserDef(key: String = Keys.mainUserDef.rawValue) {
        if let model = UserDefaultsUtils.getModel(type: UserModel.self, key: key) {
            self = model
        } else {
            BeautifulOutputer.cPrint(type: .warning, place: .medicalID, message1: "cant get from user def", message2: key)
        }
    }
    
    func compare(with userOp: UserModel?, isFamDoc: Bool = false, isUserToText: Bool = false) -> Bool {
        guard let user = userOp else { return false }
        
        if isFamDoc {
            return self.doctor?.id == user.doctor?.id
        }
        
        if isUserToText {
            return self.profile == userOp?.profile && self.doctor == userOp?.doctor
        }
        
        return self.id == user.id &&
            self.email == user.email &&
            self.number == user.number
    }
    
//    func getDiferentParams(with old: UserModel) -> Parameters {
//        var params: Parameters = [:]
//        return params
//    }
}

extension UserModel: Codable {
    private enum Keys: String, CodingKey {
        case mainUserDef = "mainMedicalUsrCardID42"
        
        case id = "id"
        case username = "username"
        case email = "email"
        case number = "mobile"
        case profile = "profile"
        case doctor = "doctor"
        case location = "location"
        case isDoctor = "isDoctor"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        
        username = try? container.decode(String.self, forKey: .username)
        email = try? container.decode(String.self, forKey: .email)
        number = try? container.decode(String.self, forKey: .number)
        profile = try? container.decode(UserCardModel.self, forKey: .profile)
        doctor = try? container.decode(DoctorModel.self, forKey: .doctor)
        //if doctor == nil, profile == nil { doctor = try? DoctorModel(from: decoder) }
        location = try? container.decode(LocationModel.self, forKey: .location)
        
        if let isD = try? container.decode(Bool.self, forKey: .isDoctor) {
            isDoctor = isD
        }
        
        userType = UserTypeEnum.determine(self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        
        try? container.encode(username, forKey: .username)
        try? container.encode(number, forKey: .number)
        try? container.encode(email, forKey: .email)
        try? container.encode(profile, forKey: .profile)
        try? container.encode(doctor, forKey: .doctor)
        try? container.encode(location, forKey: .location)
        try container.encode(isDoctor, forKey: .isDoctor)
    }
}
