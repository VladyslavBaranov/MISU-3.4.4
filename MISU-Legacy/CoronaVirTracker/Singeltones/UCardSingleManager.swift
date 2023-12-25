//
//  UCardSingleManager.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/16/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

class UCardSingleManager {
    static let shared = UCardSingleManager()
    private init () {
        user.profile = UserCardModel(id: -1000)
        user.email = "example@email.com"
        user.isCurrent = true
        getCurrUser(request: true)
    }
    
    var user: UserModel = UserModel(id: -1000)
    var familyDoctorOfUser: UserModel?
    
    func isUserToken() -> Bool {
        if KeychainUtils.getCurrentUserToken() != nil {
            return true
        }
        return false
    }
    
    func saveCurrUser(oldUser: UserModel, requestToSave: Bool = false, completion: ((Bool)->Void)? = nil) {
        user.saveToUserDef()
        print("User to save: \(user)")
        if requestToSave { saveToServer(oldUser, completion: completion) }
    }
    
    func createLocation(location: LocationModel) {
        UserManager.shared.create(newLocation: location) { (location, error) in
            print("Select location: \(String(describing: location))")
            print("Select location error: \(String(describing: error))")
        }
    }
    
    func saveToServer(_ oldUser: UserModel, completion: ((Bool)->Void)?) {
        guard let token = KeychainUtils.getCurrentUserToken() else {return}
        var isEmpty: Bool = true
        
        if let doc = user.doctor, let oldDoc = oldUser.doctor {
            let params: Parameters = doc.getDiferentParams(with: oldDoc)
            let files: Files = doc.getDiferentFiles(with: oldDoc)
            print("Doc: \(params)")
            print("Doc: \(files)")
            if !params.isEmpty {
                isEmpty = false
                UserManager.shared.updateDoctor(token, params: params, files: []) { (doctor, error) in
                    if doctor != nil {
                        ModalMessagesController.shared.show(message: "Successful update", type: .success)
                        completion?(true)
                    }
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                        completion?(false)
                    }
                }
            }
            
            if !files.isEmpty {
                isEmpty = false
                UserManager.shared.updateDoctor(token, params: [:], files: files) { (doctor, error) in
                    if doctor != nil {
                        ModalMessagesController.shared.show(message: "Successful update", type: .success)
                        completion?(true)
                    }
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                        completion?(false)
                    }
                }
            }
        }
        
        if let prof = user.profile, let oldProf = oldUser.profile {
            let params: Parameters = prof.getDiferentParams(with: oldProf)
            let files: Files = prof.getDiferentFiles(with: oldProf)
            print("Prof: \(params)")
            if !params.isEmpty {
                isEmpty = false
                UserManager.shared.updatePatient(token, params: params, files: []) { (doctor, error) in
                    if doctor != nil {
                        ModalMessagesController.shared.show(message: "Successful update", type: .success)
                        completion?(true)
                    }
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                        completion?(false)
                    }
                    
                }
            }
            print("Prof files: \(files)")
            if !files.isEmpty {
                isEmpty = false
                UserManager.shared.updatePatient(token, params: [:], files: files) { (doctor, error) in
                    if doctor != nil {
                        print("User aft up: \(String(describing: doctor))")
                        ModalMessagesController.shared.show(message: "Successful update", type: .success)
                        completion?(true)
                    }
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                        completion?(false)
                    }
                }
            }
        }
        
        
        if let profStat = user.doctor?.statistic, let oldStat = oldUser.doctor?.statistic {
            let params: Parameters = profStat.diferentParams(with: oldStat)
            print("Statistic: \(params)")
            if params.count > 0 {
                isEmpty = false
                UserManager.shared.updateIll(params: params) { (statistic, error) in
                    if statistic != nil {
                        ModalMessagesController.shared.show(message: "Successful update", type: .success)
                        completion?(true)
                    }
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                        completion?(false)
                    }
                }
            }
        }
        
        if isEmpty {
            completion?(true)
        }
        // location
        
    }
    
    func updateCurrUser(_ newUser: UserModel, requestToSave: Bool = false) {
        user = newUser
        user.saveToUserDef()
        
        //guard let token = KeychainUtils.getCurrentUserToken(), requestToSave else {return}
        //send request
    }
    
    func getPatients() -> [UserModel] {
        // send request
        return ListDHUSingleManager.shared.users
    }
    
    func getPatientStatistic() -> HealthStatisticModel {
        // send request
        var statistic = HealthStatisticModel(well: 0, weak: 0, ill: 0, dead: 0)
        getPatients().forEach { patient in
            switch patient.profile?.status {
            case .well?:
                statistic.well += 1
            case .weak?:
                statistic.weak += 1
            case .ill?:
                statistic.ill += 1
            default: break 
            }
        }
        return statistic
    }
    
    func logOutUser(_ completion: SuccessBoolCompletion? = nil) {
        guard let token = KeychainUtils.getCurrentUserToken() else {
            completion?(false)
            return
        }
        
        if token == applePatToken || token == appleDocToken { return }
        AuthManager.shared.logout(token: token) { (success, error) in
            print("Error: \(String(describing: error))")
            print("Detail: \(String(describing: success))")
            if success {
                self.clearUserData()
            }
            completion?(success)
        }
    }
    
    func deleteUser(_ completion: SuccessBoolCompletion? = nil) {
        if let token = KeychainUtils.getCurrentUserToken(),
            (token == applePatToken || token == appleDocToken) {
            logOutUser(completion)
            return
        }
        
        UserManager.shared.delete { success, error in
            if success {
                ModalMessagesController.shared.show(message: NSLocalizedString("Success", comment: ""), type: .success)
                self.clearUserData()
            }
            print("UDelete Detail: \(String(describing: success))")
            if let er = error {
                ModalMessagesController.shared.show(message: er.message, type: .error)
                print("UDelete Error: \(er)")
            }
            completion?(success)
        }
    }
    
    func clearUserData() {
        ChatsSinglManager.shared.clearCache()
        
        if KeychainUtils.removeAll() {
            print("KeychainUtils cleared...")
        }
        
        UserDefaultsUtils.removeAll()
        
        self.user = UserModel(id: -1000)
        self.user.userType = .patient
        self.familyDoctorOfUser = nil
        ListDHUSingleManager.shared.users = []
        ChatsSinglManager.shared.clearUnreadedCount()
    }
}



// MARK: - create methods
extension UCardSingleManager {
    func getUser() -> UserModel {
        user.getFromUserDef()
        user.isCurrent = true
        print("User from def: \(user)")
        return user
    }
    
    func getCurrUser(request: Bool, completion: ((UserModel) -> Void)? = nil) {
        user.getFromUserDef()
        user.isCurrent = true
        if !request { completion?(user) }
        completion?(user)
        guard let token = KeychainUtils.getCurrentUserToken() else { return }
        print(token)
        UserManager.shared.getCurrent(token) { (requestedUser, error) in
            if let usr = requestedUser {
                self.user = usr
                self.user.isCurrent = true
                self.user.userType = UserTypeEnum.determine(self.user)
                self.user.saveToUserDef()
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
            }
            completion?(self.user)
        }
    }
}



// MARK: - create methods
extension UCardSingleManager {
    func createUser() {
        var userTemp = UserModel(id: -1001)
        userTemp.email = "wish.hook@wh.com"
        userTemp.number = "+380674962499"
        userTemp.profile = UserCardModel(id: -1001)
        userTemp.profile?.name = "Nick Kononory"
        userTemp.isCurrent = true
        userTemp.userType = UserTypeEnum.determine(userTemp)
        userTemp.location = UCardSingleManager.shared.user.location
        userTemp.saveToUserDef()
    }
    
    func createDoctor() {
        var userTemp = UserModel(id: -1001)
        userTemp.email = "wish.hook@wh.com"
        userTemp.number = "+380674962499"
        userTemp.doctor = DoctorModel(id: -1001)
        userTemp.doctor?.docPost = .init(id: -1, name: "Test Post")
        userTemp.isCurrent = true
        userTemp.userType = UserTypeEnum.determine(userTemp)
        userTemp.location = UCardSingleManager.shared.user.location
        userTemp.saveToUserDef()
    }
    
    func getTestDoctor() -> UserModel {
        var userTemp = UserModel(id: -1001)
        userTemp.email = "wish.hook@wh.com"
        userTemp.number = "+380674962499"
        userTemp.doctor = DoctorModel(id: -1001)
        userTemp.doctor?.docPost = .init(id: -1, name: "Test Post")
        userTemp.isCurrent = true
        userTemp.userType = UserTypeEnum.determine(userTemp)
        userTemp.location = UCardSingleManager.shared.user.location
        return userTemp
    }
}
