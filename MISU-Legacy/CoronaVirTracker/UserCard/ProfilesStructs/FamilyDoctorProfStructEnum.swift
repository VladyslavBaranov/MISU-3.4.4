//
//  FamilyDoctorProfStructEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum FamilyDoctorProfStructEnum: Int, CaseIterable {
    case generalInfo = 0
    case statistic = 1
    case patients = 2
    case needs = 3
    case haves = 4
    case additionalInfo = 5
    case help = 6
    
    var key: String {
        return String(describing: self)
    }
    
    static var maxNumberOfPatients: Int { get { return 5 } }
    static var editCellId: String { get { return "editCellId" } }
    static var seeAllCellId: String { get { return "seeAllCellId" } }
    
    static func collectionRegisterCells(_ collectionView: UICollectionView) {
        collectionView.register(GeneralInfoHospitalViewCell.self, forCellWithReuseIdentifier: self.generalInfo.key)
        collectionView.register(StatisticHospitalViewCell.self, forCellWithReuseIdentifier: self.statistic.key)
        collectionView.register(DocNeedsCell.self, forCellWithReuseIdentifier: self.needs.key)
        collectionView.register(DocNeedsCell.self, forCellWithReuseIdentifier: self.haves.key)
        collectionView.register(UserViewCell.self, forCellWithReuseIdentifier: self.patients.key)
        collectionView.register(EditSymptomsViewCell.self, forCellWithReuseIdentifier: self.editCellId)
        collectionView.register(SeeAllViewCell.self, forCellWithReuseIdentifier: self.seeAllCellId)
        
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.needs.key)
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.haves.key)
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.patients.key)
    }
}



// MARK: - Collection delegate view methods
extension FamilyDoctorProfStructEnum {
    static func didSelectItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) {
        let frameForEdits = collectionView.controller()?.view.frame ?? .zero
        switch indexPath.section {
        case self.generalInfo.rawValue:
            if !((collectionView.controller() as? ProfileVC)?.isCurrentUser ?? false) { return }
            let editView = GeneralInfoDoctorEditView(frame: frameForEdits)
            editView.show { _ in
                (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
            }
            return
        case self.statistic.rawValue:
            if !((collectionView.controller() as? ProfileVC)?.isCurrentUser ?? false) { return }
            ListDHUTaskSingletonManager.shared.setTask(segment: .users)
            (collectionView.controller()?.tabBarController as? MainTabBarController)?.setSelectedTab(index: MainTabBarStructEnum.watch.rawValue)
            return
        case self.patients.rawValue:
            if collectionView.isLast(item: indexPath.item, inSection: indexPath.section) {
                ListDHUTaskSingletonManager.shared.setTask(segment: .users)
                (collectionView.controller()?.tabBarController as? MainTabBarController)?.setSelectedTab(index: MainTabBarStructEnum.watch.rawValue)
                return
            }
            let vc = ProfileVC()
            vc.setUser(ListDHUSingleManager.shared.users[safe: indexPath.row], isCurrent: false)
            collectionView.navigationController()?.pushViewController(vc, animated: true)
            return
        case self.needs.rawValue, self.haves.rawValue:
            if !((collectionView.controller() as? ProfileVC)?.isCurrentUser ?? false) { return }
            let editView = NeedsEditView(frame: frameForEdits)
            editView.show { _ in
                (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: true)
            }
            return
        default:
            return
        }
    }
}



// MARK: - Data Source collection view methods
extension FamilyDoctorProfStructEnum {
    static func numberOfItemsInSection(_ section: Int, user: UserModel) -> Int {
        switch section {
        case self.generalInfo.rawValue,
             self.statistic.rawValue:
            return 1
        case self.needs.rawValue:
            if let needsCount = user.doctor?.weNeedList.count, needsCount > 0 {
                return needsCount
            }
            return user.isCurrent ? 1 : 0
        case self.haves.rawValue:
            if let needsCount = user.doctor?.weHaveList.count, needsCount > 0 {
                return needsCount
            }
            return user.isCurrent ? 1 : 0
        case self.patients.rawValue:
            if !user.isCurrent { return 0 }
            let patientsCount = ListDHUSingleManager.shared.users.count > 0 ? ListDHUSingleManager.shared.users.count : 0
            return (patientsCount > maxNumberOfPatients) ? maxNumberOfPatients+1 : patientsCount+1
        default:
            return 0
        }
    }
    
    static func cellForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, user: UserModel? = nil) -> UICollectionViewCell {
        switch indexPath.section {
        case self.generalInfo.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.generalInfo.key, for: indexPath) as? GeneralInfoHospitalViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not GeneralInfoHospitalViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.doctorModel = user
            return cell
        case self.statistic.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.statistic.key, for: indexPath) as? StatisticHospitalViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not StatisticHospitalViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.statistic = user?.doctor?.statistic
            return cell
        case self.needs.rawValue:
            if (user?.doctor?.weNeedList.count ?? 0) == 0, user?.isCurrent == true  {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.editCellId, for: indexPath) as? EditSymptomsViewCell else { return UICollectionViewCell() }
                return cell
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.needs.key, for: indexPath) as? DocNeedsCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DocNeedsCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.needItem = user?.doctor?.weNeedList[safe: indexPath.row]
            return cell
        case self.haves.rawValue:
            if (user?.doctor?.weHaveList.count ?? 0) == 0, user?.isCurrent == true {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.editCellId, for: indexPath) as? EditSymptomsViewCell else { return UICollectionViewCell() }
                return cell
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.haves.key, for: indexPath) as? DocNeedsCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DocNeedsCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.needItem = user?.doctor?.weHaveList[safe: indexPath.row]
            return cell
        case self.patients.rawValue:
            if collectionView.isLast(item: indexPath.item, inSection: indexPath.section) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.seeAllCellId, for: indexPath) as? SeeAllViewCell else { return UICollectionViewCell() }
                return cell
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.patients.key, for: indexPath) as? UserViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not UserViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.userModel = ListDHUSingleManager.shared.users[safe: indexPath.row]
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    static func viewForSupplementaryElementOfKind(_ kind: String, at indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            break
        default:
            return UICollectionReusableView()
        }
        
        switch indexPath.section {
        case self.needs.rawValue:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.needs.key, for: indexPath) as? TitleCollectionReusableView else {
                return UICollectionReusableView()
            }
            headerView.titleLabel.text = "\(NSLocalizedString("We need", comment: "")):"
            return headerView
        case self.haves.rawValue:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.haves.key, for: indexPath) as? TitleCollectionReusableView else {
                return UICollectionReusableView()
            }
            headerView.titleLabel.text = "\(NSLocalizedString("We got", comment: "")):"
            return headerView
        case self.patients.rawValue:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.patients.key, for: indexPath) as? TitleCollectionReusableView else {
                return UICollectionReusableView()
            }
            headerView.titleLabel.text = "\(NSLocalizedString("Patients", comment: "")):"
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}



// MARK: - Flow Layout delegate collection view methods
extension FamilyDoctorProfStructEnum {
    static func sizeForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, layout: UICollectionViewLayout) -> CGSize {
        var w = collectionView.frame.width
        var h = collectionView.standartInset
        
        switch indexPath.section {
        case self.generalInfo.rawValue:
            h = GeneralInfoHospitalViewCell.getHeight(frame: collectionView.frame)
        case self.statistic.rawValue:
            break //h = StatisticHospitalViewCell.getHeight()
        case self.needs.rawValue,
             self.haves.rawValue:
            h = DocNeedsCell.getHeight()
            w -= collectionView.standartInset*2
        case self.patients.rawValue:
            h = UserViewCell.getHeight()
            if collectionView.isLast(item: indexPath.item, inSection: indexPath.section) {
                h = SeeAllViewCell.getHeight()
            }
            w -= collectionView.standartInset*2
        default:
            break
        }
        
        return CGSize(width: w, height: h)
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        switch section {
        case self.statistic.rawValue,
             self.needs.rawValue,
             self.haves.rawValue,
             self.patients.rawValue:
            return UIEdgeInsets(top: 0, left: 0, bottom: collectionView.standartInset, right: 0)
        default:
            return .zero
        }
    }
    
    static func referenceSizeForHeaderInSection(_ section: Int, collectionView: UICollectionView) -> CGSize {
        switch section {
        case self.needs.rawValue,
             self.haves.rawValue,
             self.patients.rawValue:
            return CGSize(width: collectionView.frame.width, height: TitleCollectionReusableView.getHeight())
        default:
            return .zero
        }
    }
    
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        switch section {
        case self.needs.rawValue,
             self.haves.rawValue,
             self.patients.rawValue:
            return collectionView.standartInset/2
        default:
            return collectionView.standartInset
        }
    }
}
