//
//  ListDHUSingleManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

class ListDHUSingleManager {
    static let shared = ListDHUSingleManager()
    
    var doctors: [UserModel] = []
    var familyDoctors: [UserModel] = []
    var hospitals: [HospitalModel] = []
    var users: [UserModel] = []
    
    var cities: CitiesListModel = .init()
    var hospitalsList: HospitalListModelT = .init()
    
    var sympthoms: [SymptomModel] = []
    var doctorPosts: [DoctorPositionModel] = []
    
    var confirmIllness: [ConstantsModel] = []
    var stateIllness: [ConstantsModel] = []
    var illnessList: [IllnessListItemModel] = []
    var vaccinesStruct: [Int:ConstantsModel] = [0:.init()]
    var vaccinesList: [ConstantsModel] = [] {
        didSet {
            vaccinesList.forEach { const in
                vaccinesStruct.updateValue(const, forKey: (const.id ?? 0)+1)
            }
        }
    }
    
    private init () {
        updateData()
        getVaccines()
    }
    
    func updateDefaultLists() {
        getSymptoms()
        getDoctorPositions()
        getIllnessList()
        getConfirmIllnesConsts()
        getStateIllnessConsts()
        getVaccines()
    }
    
    func getVaccines(_ completion: (()->Void)? = nil) {
        DefaultListManager.shared.getConstant(.vaccine) { vaccines_, error_ in
            if let vc = vaccines_ {
                self.vaccinesList = vc
            }
            
            if let er = error_ {
                print("Get vaccines ERROR: \(er.message)")
            }
            
            completion?()
        }
    }
    
    func getHospitalsList(_ hpM: HospitalListModelT = ListDHUSingleManager.shared.hospitalsList,
                          _ completion: ((HospitalListModelT)->Void)? = nil) {
        if hpM.currentPage == hpM.pages, hpM.currentPage != 0 { return }
        let hpM = hpM
        HospitalsManager.shared.getAllHospitals(hpM) { (hospLM, errorOp) in
            //print("### HOSPS \(String(describing: hospLM))")
            if let _hospitalList = hospLM {
                if _hospitalList.list.last?.id == hpM.list.last?.id, hpM.list.last != nil {
                    hpM.pages = hpM.currentPage
                } else {
                    hpM.list.append(contentsOf: _hospitalList.list)
                    hpM.currentPage += 1
                }
                if hpM.city == nil || hpM.city == "" { self.hospitalsList = hpM }
                print("Get cities page Success: \(hpM.list.count)")
            }
            
            if let er = errorOp {
                print("Get cities page Error: \(hpM.currentPage + 1) \(hpM.city ?? "nil") \(er)")
            }
            
            completion?(hpM)
        }
    }
    
    func getCities(_ completion: ((CitiesListModel)->Void)? = nil) {
        if cities.currentPage == cities.pages, cities.currentPage != 0 { return }
        
        HospitalsManager.shared.getCities(listModel: cities) { [self] (pageList, error) in
            if let _pageList = pageList {
                cities.list.append(contentsOf: _pageList.list)
                cities.currentPage += 1
                print("Get cities page Success: \(_pageList.list.count)")
            }
            
            if let er = error {
                print("Get cities page Error: \(cities.currentPage + 1) \(er)")
            }
            
            completion?(cities)
        }
    }
    
    private func getStateIllnessConsts() {
        MedicalHistoryManager.shared.stateConsts { (listOp, error) in
            if let list = listOp {
                self.stateIllness = list
            }
            if let er = error {
                print("Get all stateIllness Error: \(er)")
            }
        }
    }
    
    private func getConfirmIllnesConsts() {
        MedicalHistoryManager.shared.confirmConsts { (listOp, error) in
            if let list = listOp {
                self.confirmIllness = list
            }
            if let er = error {
                print("Get all confirmIllness Error: \(er)")
            }
        }
    }
    
    private func getIllnessList() {
        MedicalHistoryManager.shared.illnessList { (listOp, error) in
            if let list = listOp {
                self.illnessList = list
            }
            if let er = error {
                print("Get all illness Error: \(er)")
            }
        }
    }
    
    private func getSymptoms() {
        DefaultListManager.shared.getSymptoms { (symptomsOp, error) in
            if let symp = symptomsOp {
                self.sympthoms = symp
            }
            if let er = error {
                print("Get all sympthoms Error: \(er)")
                //self.getSymptoms()
            }
        }
    }
    
    private func getDoctorPositions() {
        DefaultListManager.shared.getPositions { (positionsOp, error) in
            if let pos = positionsOp {
                self.doctorPosts = pos
            }
            if let er = error {
                print("Get all sympthoms Error: \(er)")
                //self.getDoctorPositions()
            }
        }
    }
    
    func requestAllUsers() {
        UsersListManager.shared.getAllUsers(one: false) { (usersList, error) in
            if let error = error {
                BeautifulOutputer.cPrint(type: .warning, place: .usersSingleM, message1: error.error, message2: String(describing: error))
            }
            
            if let list = usersList {
                for item in list {
                    print(item)
                }
            }
        }
    }
    
    func updateData(_ completion: (() -> Void)? = nil) {
        ListDHManager.shared.getAllDoctors(one: false) { (doctorsOp, error) in
            if var docs = doctorsOp, !docs.isEmpty {
                (0...docs.count-1).forEach { index in
                    docs[index].userType = .doctor
                }
                self.doctors = docs
            }
            if let err = error {
                print(err)
            }
        }
        
        ListDHManager.shared.getAllHospitals(one: false) { (hospitalsOp, error) in
            if let hosp = hospitalsOp {
                self.hospitals = hosp
            }
            if let err = error {
                print(err)
            }
            
            completion?()
        }
        
        guard let token = KeychainUtils.getCurrentUserToken(), UCardSingleManager.shared.user.userType != UserTypeEnum.patient else { return }
        ListDHManager.shared.getGetPatientsOfCurrentDoctor(token: token) { (patientsListOp, error) in
            //print("Pat list: \(patientsListOp)")
            if var patients = patientsListOp {
                if patients.count > 0 {
                    (0...patients.count-1).forEach { index in
                        patients[index].userType = .patient
                        patients[index].profile?.familyDoctor = UCardSingleManager.shared.user.doctor
                    }
                    self.users = patients
                }
            }
            
            if let er = error {
                print("Get patients of cur doc Error: \(er)")
            }
        }
    }
}
