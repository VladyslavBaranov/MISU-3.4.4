//
//  HospitalStructEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 14.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum HospitalStructEnum: Int {
    case generalInfo = 0
    case statistic = 1
    case needs = 2
    case haves = 3
    case doctors = 4
}

extension HospitalStructEnum: CustomEnumStruct {
    var cellClass: AnyClass {
        switch self {
        case .generalInfo:
            return GeneralInfoHospitalViewCell.self
        case .statistic:
            return StatisticHospitalViewCell.self
        case .needs, .haves:
            return NeedsHavesCVCell.self
        case .doctors:
            return DoctorsCVCell.self
        }
    }
    
    static func numberOfSections() -> Int {
        return 1
    }
    
    static func numberOfItemsInSection<T>(_ section: Int, info: T?) -> Int {
        return allCases.count
    }
    
    static func didSelectItemAt<T>(_ indexPath: IndexPath, collectionView: UICollectionView, info: T?, completionAfterEdit: (() -> Void)?) {
    }
    
    static func willDisplay<T>(_ cell: UICollectionViewCell, collectionView: UICollectionView, forItemAt indexPath: IndexPath, info: T?) {
        let hosp = info as? HospitalModel
        switch allCases[safe: indexPath.item] {
        case .generalInfo:
            (cell as? GeneralInfoHospitalViewCell)?.hospital = hosp
        case .needs:
            (cell as? NeedsHavesCVCell)?.needItems = hosp?.needs ?? []
        case .haves:
            (cell as? NeedsHavesCVCell)?.haveItems = hosp?.haves ?? []
        case .doctors:
            (cell as? DoctorsCVCell)?.doctors = hosp?.doctors ?? []
        default:
            break
        }
    }
    
    static func minimumInteritemSpacingForSectionAt(section: Int, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        return 0
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: collectionView.standartInset, right: 0)
    }
    
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        return collectionView.standartInset
    }
}
