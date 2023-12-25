//
//  SettingsTabelViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 13.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - TableView Delegate
extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = userModel?.userType else { return }
        switch type {
        case .patient:
            PatientSettingsStruct.didSelectRowAt(indexPath, tableView: tableView)
        case .doctor, .familyDoctor:
            DoctorSettingsStruct.didSelectRowAt(indexPath, tableView: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let type = userModel?.userType else { return 0 }
        switch type {
        case .patient:
            return PatientSettingsStruct.heightForRowAt(indexPath, tableView: tableView)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.heightForRowAt(indexPath, tableView: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let type = userModel?.userType else { return nil }
        switch type {
        case .patient:
            return PatientSettingsStruct.viewForHeaderInSection(section)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.viewForHeaderInSection(section)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let type = userModel?.userType else { return nil }
        switch type {
        case .patient:
            return PatientSettingsStruct.viewForFooterInSection(section)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.viewForFooterInSection(section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let type = userModel?.userType else { return 0 }
        switch type {
        case .patient:
            return PatientSettingsStruct.heightForFooterInSection(section)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.heightForFooterInSection(section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let type = userModel?.userType else { return 0 }
        switch type {
        case .patient:
            return PatientSettingsStruct.heightForHeaderInSection(section)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.heightForHeaderInSection(section)
        }
    }
}



// MARK: - Data Source
extension SettingsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let type = userModel?.userType else { return 0 }
        switch type {
        case .patient:
            return PatientSettingsStruct.allCases.count
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = userModel?.userType else { return 0 }
        switch type {
        case .patient:
            return PatientSettingsStruct.numberOfRowsInSection(section)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.numberOfRowsInSection(section)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = userModel?.userType else { return UITableViewCell() }
        switch type {
        case .patient:
            return PatientSettingsStruct.cellForRowAt(indexPath, tableView: tableView, user: editedUserModel)
        case .doctor, .familyDoctor:
            return DoctorSettingsStruct.cellForRowAt(indexPath, tableView: tableView, user: editedUserModel)
        }
    }
}
