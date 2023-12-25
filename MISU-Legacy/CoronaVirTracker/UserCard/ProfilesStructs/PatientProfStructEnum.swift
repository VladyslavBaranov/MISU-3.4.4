//
//  PatientProfStructEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum PatientProfStructEnum: Int, CaseIterable {
    case generalInfoP = 0
    case symptoms = 1
    case illness = 2
    case healthParams = 3
    case familyDoctor = 4
    case needs = 5
    
    var key: String {
        return String(describing: self)
    }
    
    enum healthParamsStruct: Int, CaseIterable {
        case sugar = 0
        case insulin = 1
        
        case bloodOxygen = 2
        case heartBeat = 3
        case temperature = 4
        
        static var currentCount: Int { get { return 2 } }
        
        var key: String { get { return String(describing: self) } }
        var headersParamEnum: HeadersParamEnum? {
            get {
                switch self {
                case .bloodOxygen:
                    return .bloodOxygen
                case .heartBeat:
                    return .heartBeat
                case .temperature:
                    return .temperature
                default:
                    return nil
                }
            }
        }
    }
    
    static var isHealthParamsHidden: Bool {
        get { return UserDefaultsUtils.getBool(key: "isHeal@thParamsHidd#en42aokd$spkasldlm%^&e1jio") ?? false }
        set(newValue) { UserDefaultsUtils.save(value: newValue, key: "isHeal@thParamsHidd#en42aokd$spkasldlm%^&e1jio") }
    }
    
    static func collectionRegisterCells(_ collectionView: UICollectionView) {
        collectionView.register(GeneralInfoPatientViewCell.self, forCellWithReuseIdentifier: self.generalInfoP.key)
        collectionView.register(SymptomsPatientViewCell.self, forCellWithReuseIdentifier: self.symptoms.key)
        collectionView.register(DocNeedsCell.self, forCellWithReuseIdentifier: self.healthParams.key)
        collectionView.register(FamilyDoctorViewCell.self, forCellWithReuseIdentifier: self.familyDoctor.key)
        collectionView.register(SymptomViewCell.self, forCellWithReuseIdentifier: self.illness.key)
        
        collectionView.register(ParamChartViewCell.self, forCellWithReuseIdentifier: self.healthParamsStruct.bloodOxygen.key)
        collectionView.register(ParamChartViewCell.self, forCellWithReuseIdentifier: self.healthParamsStruct.heartBeat.key)
        collectionView.register(ParamChartViewCell.self, forCellWithReuseIdentifier: self.healthParamsStruct.temperature.key)
        
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.symptoms.key)
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.healthParams.key)
        collectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.familyDoctor.key)
    }
}



// MARK: - Collection delegate view methods
extension PatientProfStructEnum {
    static func didSelectItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, user: UserModel?, isCurrent: Bool, completionAfterEdit: ((Bool) -> Void)? = nil) {
        let frameForEdits = collectionView.controller()?.view.frame ?? .zero
        if !isCurrent, indexPath.section == self.healthParams.rawValue {
            switch indexPath.row {
            case self.healthParamsStruct.sugar.rawValue:
                let vc = SugarInsulinHistoryVC(selectedTab: .sugar, user: user)
                vc.hidesBottomBarWhenPushed = true
                collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
            case self.healthParamsStruct.insulin.rawValue:
                let vc = SugarInsulinHistoryVC(selectedTab: .insuline, user: user)
                vc.hidesBottomBarWhenPushed = true
                collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
            default:
                return
            }
        }
        if !isCurrent, indexPath.section != self.familyDoctor.rawValue, indexPath.section != self.illness.rawValue { return }
        switch indexPath.section {
        case self.generalInfoP.rawValue:
            let editView = GeneralInfoPatientEditView(frame: frameForEdits)
            editView.show { _ in
                completionAfterEdit?(true)
            }
            return
        case self.healthParams.rawValue:
            switch indexPath.row {
            case self.healthParamsStruct.sugar.rawValue:
                let vc = SugarInsulinHistoryVC(selectedTab: .sugar)
                vc.hidesBottomBarWhenPushed = true
                collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
            case self.healthParamsStruct.insulin.rawValue:
                let vc = SugarInsulinHistoryVC(selectedTab: .insuline)
                vc.hidesBottomBarWhenPushed = true
                collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
            default:
                return
            }
            return
        case self.familyDoctor.rawValue:
            if isCurrent {
                guard let familyDoc = user?.profile?.getFamilyDoctorUserModel() else {
                    let selectFamDocView = SelectFamilyDoctorView(frame: collectionView.controller()?.view.frame ?? .zero)
                    selectFamDocView.show { _ in
                        (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
                    }
                    return
                }
                let vc = ProfileVC()
                vc.setUser(familyDoc, isCurrent: false)
                collectionView.navigationController()?.pushViewController(vc, animated: true)
                return
            }
            guard let familyDoc = user?.profile?.getFamilyDoctorUserModel() else { return }
            let vc = ProfileVC()
            vc.setUser(familyDoc, isCurrent: false)
            collectionView.navigationController()?.pushViewController(vc, animated: true)
            return
        case self.illness.rawValue:
            guard let us = user else { return }
            let vc = us.isCurrent ? IllnessHistoryVC() : IllnessHistoryVC(user: user)
            vc.hidesBottomBarWhenPushed = true
            collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
}



// MARK: - Data Source collection view methods
extension PatientProfStructEnum {
    static func numberOfItemsInSection(_ section: Int, isCurrent: Bool) -> Int {
        switch section {
        case self.healthParams.rawValue:
            if isHealthParamsHidden { return 0 }
            if !isCurrent { return healthParamsStruct.allCases.count }
            return healthParamsStruct.currentCount
        case self.generalInfoP.rawValue,
             self.symptoms.rawValue,
             self.familyDoctor.rawValue,
             self.illness.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    static func cellForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, user: UserModel? = nil) -> UICollectionViewCell {
        switch indexPath.section {
        case self.generalInfoP.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.generalInfoP.key, for: indexPath) as? GeneralInfoPatientViewCell else { return UICollectionViewCell() }
            cell.userModel = user
            return cell
        case self.symptoms.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.symptoms.key, for: indexPath) as? SymptomsPatientViewCell else { return UICollectionViewCell() }
            cell.userModel = user
            return cell
        case self.healthParams.rawValue:
            switch healthParamsStruct.allCases[safe: indexPath.row] {
            case .sugar, .insulin:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.healthParams.key, for: indexPath) as? DocNeedsCell else { return UICollectionViewCell() }
                if healthParamsStruct.allCases[safe: indexPath.row] == .sugar {
                    cell.sugarValue = user?.profile?.bloodSugar?.value
                } else {
                    cell.insulinValue = user?.profile?.insulinValue?.value
                }
                return cell
            case .bloodOxygen, .heartBeat, .temperature:
                guard let type = self.healthParamsStruct.allCases[safe: indexPath.item] else { return UICollectionViewCell() }
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type.key, for: indexPath) as? ParamChartViewCell else { return UICollectionViewCell() }
                cell.healthType = type.headersParamEnum
                cell.user = user
                return cell
            default:
                return UICollectionViewCell()
            }
        case self.illness.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.illness.key, for: indexPath) as? SymptomViewCell else {
                return UICollectionViewCell()
            }
            cell.title = NSLocalizedString("Medical history", comment: "")
            cell.contentView.backgroundColor = UIColor.appDefault.red
            cell.titleLabel.textColor = .white
            return cell
        case self.familyDoctor.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.familyDoctor.key, for: indexPath) as? FamilyDoctorViewCell else { return UICollectionViewCell() }
            cell.isCurent = user?.isCurrent
            cell.doctorModel = user?.profile?.getFamilyDoctorUserModel()
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
        case self.symptoms.rawValue:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.symptoms.key, for: indexPath) as? TitleCollectionReusableView else { return UICollectionReusableView() }
            headerView.titleLabel.text = "\(NSLocalizedString("Symptoms", comment: "")):"
            return headerView
        case self.healthParams.rawValue:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.healthParams.key, for: indexPath) as? TitleCollectionReusableView else { return UICollectionReusableView() }
            headerView.titleLabel.text = "\(NSLocalizedString("Medical tests", comment: "")):"
            headerView.hideShowAction = .some({ () -> Bool in
                isHealthParamsHidden = !isHealthParamsHidden
                collectionView.reloadData()
                return isHealthParamsHidden
            })
            headerView.isHiddenContext = isHealthParamsHidden
            return headerView
        case self.familyDoctor.rawValue:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.familyDoctor.key, for: indexPath) as? TitleCollectionReusableView else { return UICollectionReusableView() }
            headerView.titleLabel.text = "\(NSLocalizedString("Family doctor", comment: "")):"
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}



// MARK: - Flow Layout delegate collection view methods
extension PatientProfStructEnum {
    static func sizeForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, layout: UICollectionViewLayout, user: UserModel) -> CGSize {
        var w = collectionView.frame.width
        var h = collectionView.standartInset
        
        switch indexPath.section {
        case self.generalInfoP.rawValue:
            h = GeneralInfoPatientViewCell.getHeight(frame: CGRect(origin: .zero, size: CGSize(width: w, height: 16)))
        case self.symptoms.rawValue:
            if !user.isCurrent, user.profile?.symptoms.count == 0 {
                h = collectionView.standartInset/2
            } else {
                h = SymptomViewCell.getHeight() + collectionView.standartInset/2
            }
        case self.healthParams.rawValue:
            let type = self.healthParamsStruct.allCases[safe: indexPath.item]
            w -= collectionView.standartInset*2
            if type == .sugar || type == .insulin {
                h = DocNeedsCell.getHeight()
            } else {
                h = w
            }
        case self.familyDoctor.rawValue:
            w -= collectionView.standartInset*2
            h = FamilyDoctorViewCell.getHeight()
        case self.illness.rawValue:
            w -= collectionView.standartInset*2
            h = SymptomViewCell.getHeight()
        default:
            break
        }
        return CGSize(width: w, height: h)
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        switch PatientProfStructEnum.allCases[safe: section] {
        case .generalInfoP, .healthParams:
            return UIEdgeInsets(top: 0, left: 0, bottom: collectionView.standartInset, right: 0)
        case .illness:
            return UIEdgeInsets(top: collectionView.standartInset, left: 0, bottom: collectionView.standartInset, right: 0)
        case .familyDoctor:
            return UIEdgeInsets(top: 0, left: 0, bottom: collectionView.standartInset*1.5, right: 0)
        default:
            return .zero
        }
    }
    
    static func referenceSizeForHeaderInSection(_ section: Int, collectionView: UICollectionView) -> CGSize {
        switch section {
        case self.symptoms.rawValue,
             self.healthParams.rawValue,
             self.familyDoctor.rawValue:
            return CGSize(width: collectionView.frame.width, height: TitleCollectionReusableView.getHeight())
        default:
            return .zero
        }
    }
    
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        switch section {
        case self.healthParams.rawValue:
            return collectionView.standartInset/2
        default:
            return collectionView.standartInset
        }
    }
}
