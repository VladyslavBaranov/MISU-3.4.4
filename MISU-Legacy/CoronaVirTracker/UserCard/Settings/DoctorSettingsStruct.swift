//
//  DoctorSettingsStruct.swift
//  CoronaVirTracker
//
//  Created by WH ak on 13.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum DoctorSettingsStruct: Int, CaseIterable {
    case general = 0
    case credentials = 1
    case logOut = 2
    
    enum generalCells: Int, CaseIterable {
        case nameAndPhoto = 0
        case diplomaNumber = 1
        case hospital = 2
    }
    
    enum credentialsCells: Int, CaseIterable {
        case number = 0
    }
    
    static var hospitalCellId: String {
        get { return "hospitalCellId" }
    }
    
    struct credentialsCellIds {
        static let number = "numberCellId"
    }
    
    enum logOutCellIds: String, CaseIterable {
        case clearCache = "clearCacheCellId"
        case logOut = "logoutCellId"
        case delete = "deleteProfileCellId"
        
        var index: Int {
            get { return logOutCellIds.allCases.firstIndex(where: {$0.rawValue == self.rawValue}) ?? -1 }
        }
    }
    
    static var stamdartInset: CGFloat {
        get {
            return 16
        }
    }
}

extension DoctorSettingsStruct {
    static func didSelectRowAt(_ indexPath: IndexPath, tableView: UITableView) {
        switch indexPath {
        case IndexPath(row: self.generalCells.hospital.rawValue, section: self.general.rawValue):
            let selectFamDocView = HospitalSelectView(frame: tableView.controller()?.view.frame ?? .zero)
            selectFamDocView.show { _ in
                (tableView.controller() as? SettingsVC)?.editedUserModel?.doctor?.hospitalModel = UCardSingleManager.shared.user.doctor?.hospitalModel
                tableView.reloadData()
            }
            return
        case IndexPath(row: self.logOutCellIds.clearCache.index, section: self.logOut.rawValue):
            (tableView.controller() as? SettingsVC)?.clearCacheTapped(sender: tableView.cellForRow(at: indexPath))
            return
        case IndexPath(row: self.logOutCellIds.logOut.index, section: self.logOut.rawValue):
            (tableView.controller() as? SettingsVC)?.logOutNavButtonTapped(sender: tableView.cellForRow(at: indexPath))
            return
        case IndexPath(row: self.logOutCellIds.delete.index, section: self.logOut.rawValue):
            DeleteProfilePV().show { success in
                guard success else { return }
                tableView.navigationController()?.popToRootViewController(animated: true)
            }
            return
        default:
            return
        }
    }
    
    static func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case self.general.rawValue:
            return generalCells.allCases.count
        case self.credentials.rawValue:
            return credentialsCells.allCases.count
        case self.logOut.rawValue:
            return self.logOutCellIds.allCases.count
        default:
            return 0
        }
    }
    
    static func cellForRowAt(_ indexPath: IndexPath, tableView: UITableView, user: UserModel?) -> UITableViewCell {
        switch indexPath {
        case IndexPath(row: self.generalCells.nameAndPhoto.rawValue, section: self.general.rawValue):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellIds.editableCell, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell()}
            cell.setUp(placeholder: "Full Name", text: user?.doctor?.fullName) { newValue in
                (tableView.controller() as? SettingsVC)?.editedUserModel?.doctor?.fullName = newValue
            }
            cell.textField.font = UIFont.systemFont(ofSize: 24)
            
            let image = user?.doctor?.image ?? ImageCM.shared.get(byLink: user?.doctor?.imageURL) { imageReq in
                DispatchQueue.main.async { cell.imageView?.image = imageReq }
            }
            cell.imageView?.image = image ?? UIImage(named: "patientDefImage")
            
            if let target = (tableView.controller() as? SettingsVC) {
                cell.imageView?.addTapRecognizer(target, action: #selector(target.pickerImageActionRecog))
            }
            cell.addEditImage = true
            return cell
        case IndexPath(row: self.generalCells.diplomaNumber.rawValue, section: self.general.rawValue):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellIds.editableCell, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
            cell.setUp(placeholder: NSLocalizedString("Number of a diploma №...", comment: ""), text: user?.doctor?.diplomaId) { newValue in
                (tableView.controller() as? SettingsVC)?.editedUserModel?.doctor?.diplomaId = newValue
            }
            cell.isImageRounded = false
            cell.imageView?.image = UIImage(named: "TabBar_Bookmark")
            return cell
        case IndexPath(row: self.generalCells.hospital.rawValue, section: self.general.rawValue):
            var cell = CustomTableViewCell(style: .value1, reuseIdentifier: self.hospitalCellId)
            if let deqCell = tableView.dequeueReusableCell(withIdentifier: self.hospitalCellId) as? CustomTableViewCell {
                cell = deqCell
            }
            cell.textLabel?.text = NSLocalizedString("Hospital", comment: "")+":"
            cell.detailTextLabel?.text = UCardSingleManager.shared.user.doctor?.hospitalModel?.fullName ?? "-"
            cell.imageView?.image = UIImage(named: "defaultHospitalIcon")
            cell.accessoryType = .disclosureIndicator
            return cell
        case IndexPath(row: self.credentialsCells.number.rawValue, section: self.credentials.rawValue):
            var cell = CustomTableViewCell(style: .value1, reuseIdentifier: self.credentialsCellIds.number)
            if let deqCell = tableView.dequeueReusableCell(withIdentifier: self.credentialsCellIds.number) as? CustomTableViewCell {
                cell = deqCell
            }
            cell.textLabel?.text = NSLocalizedString("Number:", comment: "")
            cell.detailTextLabel?.text = user?.number ?? "-"
            cell.imageView?.image = UIImage(named: "defaultPhone")
            return cell
        case IndexPath(row: self.logOutCellIds.clearCache.index, section: self.logOut.rawValue):
            var cell = CustomTableViewCell(style: .default, reuseIdentifier: self.logOutCellIds.clearCache.rawValue)
            if let deqCell = tableView.dequeueReusableCell(withIdentifier: self.logOutCellIds.clearCache.rawValue) as? CustomTableViewCell {
                cell = deqCell
            }
            cell.textLabel?.text = NSLocalizedString("Clear cache", comment: "") + " (\(ImageCM.shared.covertToString(size: (ImageCM.shared.getSize() ?? 0) + (ChatCM.shared.getSize() ?? 0))))"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.systemBlue
            return cell
        case IndexPath(row: self.logOutCellIds.logOut.index, section: self.logOut.rawValue):
            var cell = CustomTableViewCell(style: .default, reuseIdentifier: self.logOutCellIds.logOut.rawValue)
            if let deqCell = tableView.dequeueReusableCell(withIdentifier: self.logOutCellIds.logOut.rawValue) as? CustomTableViewCell {
                cell = deqCell
            }
            cell.textLabel?.text = NSLocalizedString("Log out", comment: "")
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.appDefault.red
            return cell
        case IndexPath(row: self.logOutCellIds.delete.index, section: self.logOut.rawValue):
            var cell = CustomTableViewCell(style: .default, reuseIdentifier: self.logOutCellIds.delete.rawValue)
            if let deqCell = tableView.dequeueReusableCell(withIdentifier: self.logOutCellIds.delete.rawValue) as? CustomTableViewCell {
                cell = deqCell
            }
            cell.textLabel?.text = NSLocalizedString("Delete profile", comment: "")
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.font = .systemFont(ofSize: 14)
            cell.backgroundColor = .clear
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    static func heightForRowAt(_ indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        switch indexPath {
        case IndexPath(row: self.generalCells.nameAndPhoto.rawValue, section: self.general.rawValue):
            return tableView.standartInset*5
        default:
            return tableView.standartInset*2.5
        }
    }
    
    static func heightForHeaderInSection(_ section: Int) -> CGFloat {
        switch section {
        case self.credentials.rawValue, self.logOut.rawValue:
            return stamdartInset*2
        default:
            return 0
        }
    }
    
    static func heightForFooterInSection(_ section: Int) -> CGFloat {
        switch section {
        case self.logOut.rawValue:
            return stamdartInset*2
        default:
            return 0
        }
    }
    
    static func viewForHeaderInSection(_ section: Int) -> UIView? {
        switch section {
        case self.credentials.rawValue, self.logOut.rawValue:
            let v = UIView()
            v.backgroundColor = .clear
            return UIView()
        default:
            return nil
        }
    }
    
    static func viewForFooterInSection(_ section: Int) -> UIView? {
        switch section {
        case self.logOut.rawValue:
            let v = UIView()
            v.backgroundColor = .clear
            return UIView()
        default:
            return nil
        }
    }
}
