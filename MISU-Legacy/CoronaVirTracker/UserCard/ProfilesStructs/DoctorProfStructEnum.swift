//
//  DoctorProfStructEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum DoctorProfStructEnum: Int, CaseIterable {
    case generalInfo = 0
    case statistic = 1
    case needs = 2
    case haves = 3
    case additionalInfo = 4
    case help = 5
    
    var key: String {
        return String(describing: self)
    }
    
    static var editCellId: String { get { return "editCell" } }
    
    static func collectionRegisterCells(_ collectionView: UICollectionView) {
        collectionView.register(GeneralInfoHospitalViewCell.self, forCellWithReuseIdentifier: self.generalInfo.key)
        collectionView.register(StatisticHospitalViewCell.self, forCellWithReuseIdentifier: self.statistic.key)
        collectionView.register(DocNeedsCell.self, forCellWithReuseIdentifier: self.needs.key)
        collectionView.register(DocNeedsCell.self, forCellWithReuseIdentifier: self.haves.key)
        collectionView.register(EditSymptomsViewCell.self, forCellWithReuseIdentifier: self.editCellId)
        
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.needs.key)
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.haves.key)
    }
}



// MARK: - Collection delegate view methods
extension DoctorProfStructEnum {
    static func didSelectItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, user: UserModel?, isCurrent: Bool) {
        if !isCurrent { return }
        let frameForEdits = collectionView.controller()?.view.frame ?? .zero
        switch indexPath.section {
        case self.generalInfo.rawValue:
            let editView = GeneralInfoDoctorEditView(frame: frameForEdits)
            editView.show { _ in
                (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
            }
        case self.statistic.rawValue:
            let editView = StatisticEditView(frame: frameForEdits)
            editView.show { _ in
                (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
            }
        case self.needs.rawValue, self.haves.rawValue:
            if !isCurrent { return }
            let editView = NeedsEditView(frame: frameForEdits)
            editView.show { _ in
                (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
            }
            return
        default:
            return
        }
    }
}

 

// MARK: - Data Source collection view methods
extension DoctorProfStructEnum {
    static func numberOfItemsInSection(_ section: Int, doctor: DoctorModel, isCurrent: Bool) -> Int {
        switch section {
        case self.generalInfo.rawValue,
             self.statistic.rawValue:
            return 1
        case self.needs.rawValue:
            if !isCurrent {return doctor.weNeedList.count}
            return (doctor.weNeedList.count > 0) ? doctor.weNeedList.count : 1
        case self.haves.rawValue:
            if !isCurrent {return doctor.weHaveList.count}
            return (doctor.weHaveList.count > 0) ? doctor.weHaveList.count : 1
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
            if (user?.doctor?.weNeedList.count ?? 0) == 0, user?.isCurrent == true {
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
        default:
            return UICollectionReusableView()
        }
    }
}



// MARK: - Flow Layout delegate collection view methods
extension DoctorProfStructEnum {
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
        default:
            break
        }
        
        return CGSize(width: w, height: h)
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        switch section {
        case self.statistic.rawValue,
             self.needs.rawValue,
             self.haves.rawValue:
            return UIEdgeInsets(top: 0, left: 0, bottom: collectionView.standartInset, right: 0)
        default:
            return .zero
        }
    }
    
    static func referenceSizeForHeaderInSection(_ section: Int, collectionView: UICollectionView) -> CGSize {
        switch section {
        case self.needs.rawValue,
             self.haves.rawValue:
            return CGSize(width: collectionView.frame.width, height: TitleCollectionReusableView.getHeight())
        default:
            return .zero
        }
    }
    
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        switch section {
        case self.needs.rawValue,
             self.haves.rawValue:
            return collectionView.standartInset/2
        default:
            return collectionView.standartInset
        }
    }
}
