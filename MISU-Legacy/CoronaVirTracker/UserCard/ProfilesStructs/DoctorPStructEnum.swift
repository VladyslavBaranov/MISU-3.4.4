//
//  DoctorPStructEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 20.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum DoctorPStructEnum: Int {
    case generalInfoDoc = 0
    case statistic = 1
    case needs = 2
    case haves = 3
    
    var cellClass: AnyClass {
        switch self {
        case .generalInfoDoc:
            return GeneralInfoHospitalViewCell.self
        case .statistic:
            return StatisticHospitalViewCell.self
        case .needs, .haves:
            return NeedsHavesCVCell.self
        }
    }
}

extension DoctorPStructEnum: CustomEnumStruct {
    static func numberOfSections() -> Int {
        return 1
    }
    
    static func numberOfItemsInSection<T>(_ section: Int, info: T?) -> Int {
        return allCases.count
    }
    
    static func didSelectItemAt<T>(_ indexPath: IndexPath, collectionView: UICollectionView, info: T?, completionAfterEdit: (() -> Void)?) {
        let user = info as? UserModel
        if user?.isCurrent == false { return }
        let frameForEdits = collectionView.controller()?.view.frame ?? .zero
        switch allCases[safe: indexPath.item] {
        case .generalInfoDoc:
            let editView = GeneralInfoDoctorEditView(frame: frameForEdits)
            editView.show { _ in completionAfterEdit?() }
        case .statistic:
            if user?.userType == .familyDoctor {
                ListDHUTaskSingletonManager.shared.setTask(segment: .users)
                (collectionView.controller()?.tabBarController as? MainTabBarController)?.setSelectedTab(index: MainTabBarStructEnum.watch.rawValue)
                return
            }
            let editView = StatisticEditView(frame: frameForEdits)
            editView.show { _ in completionAfterEdit?() }
        case .needs, .haves:
            let editView = NeedsEditView(frame: frameForEdits)
            editView.show { _ in completionAfterEdit?() }
        default:
            return
        }
    }
    
    static func willDisplay<T>(_ cell: UICollectionViewCell, collectionView: UICollectionView, forItemAt indexPath: IndexPath, info: T?) {
        let user = info as? UserModel
        switch allCases[safe: indexPath.item] {
        case .generalInfoDoc:
            (cell as? GeneralInfoHospitalViewCell)?.doctorModel = user
        case .statistic:
            (cell as? StatisticHospitalViewCell)?.statistic = user?.doctor?.statistic
        case .needs:
            (cell as? NeedsHavesCVCell)?.needItems = user?.doctor?.weNeedList ?? []
        case .haves:
            (cell as? NeedsHavesCVCell)?.haveItems = user?.doctor?.weHaveList ?? []
        default:
            return
        }
    }
    
    static func minimumInteritemSpacingForSectionAt(section: Int, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        return .zero
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: collectionView.standartInset, right: 0)
    }
    
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        return collectionView.standartInset
    }
}
