//
//  PatientPStructEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum PatientPStructEnum: Int, CustomEnumStruct {
    case generalInfoPat = 0
    case hParamsPat = 1
    case otherSection = 2
    
    var cellClass: AnyClass {
        switch self {
        case .generalInfoPat:
            return GeneralInfoPatientViewCell.self
        case .hParamsPat:
            return HealthParamsCVCell.self
        default:
            return UICollectionViewCell.self
        }
    }
}



// MARK: - Collection delegate view methods
extension PatientPStructEnum {
    static func didSelectItemAt<T>(_ indexPath: IndexPath, collectionView: UICollectionView, info: T?, completionAfterEdit: (() -> Void)?) {
        switch allCases[safe: indexPath.section] {
        case .generalInfoPat:
            guard (info as? UserModel)?.isCurrent == true else { return }
            let editView = GeneralInfoPatientEditView(frame: collectionView.frame)
            editView.show { _ in
                completionAfterEdit?()
            }
            return
        case .hParamsPat:
            (collectionView.cellForItem(at: indexPath) as? HealthParamsCVCell)?.goToAllCharts()
        case .otherSection:
            OtherSectionEnum.didSelectItemAt(indexPath, collectionView: collectionView, info: info, completionAfterEdit: completionAfterEdit)
        default:
            return
        }
    }
}



// MARK: - Data Source collection view methods
extension PatientPStructEnum {
    static func numberOfSections() -> Int {
        return self.allCases.count
    }
    
    static func numberOfItemsInSection<T>(_ section: Int, info: T?) -> Int {
        switch allCases[safe: section] {
        case .generalInfoPat, .hParamsPat:
            return 1
        case .otherSection:
            return OtherSectionEnum.numberOfItemsInSection(section, info: info)
        default:
            return .zero
        }
    }
    static func willDisplay<T>(_ cell: UICollectionViewCell, collectionView: UICollectionView, forItemAt indexPath: IndexPath, info: T?) {
        let user = info as? UserModel
        switch allCases[safe: indexPath.section] {
        case .generalInfoPat:
            (cell as? GeneralInfoPatientViewCell)?.userModel = user
        case .hParamsPat:
            if user?.isCurrent == true {
                pass
            } else {
                (cell as? HealthParamsCVCell)?.userModel = user
            }
            (cell as? HealthParamsCVCell)?.requestHParams()
        case .otherSection:
            OtherSectionEnum.willDisplay(cell, collectionView: collectionView, forItemAt: indexPath, info: info)
        default:
            break
        }
    }
    
    static func customCellForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        switch allCases[safe: indexPath.section]  {
        case .generalInfoPat, .hParamsPat:
            return cellForItemAt(IndexPath(item: indexPath.section, section: indexPath.section), collectionView: collectionView)
        case .otherSection:
            return OtherSectionEnum.cellForItemAt(indexPath, collectionView: collectionView)
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: nilCellKey, for: indexPath)
        }
    }
}



// MARK: - Flow Layout delegate collection view methods
extension PatientPStructEnum {
    static func sizeForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, layout: UICollectionViewLayout) -> CGSize {
        var w = collectionView.frame.width
        var h = collectionView.standartInset
        
        switch allCases[safe: indexPath.section] {
        case .generalInfoPat:
            h = GeneralInfoPatientViewCell.getHeight(frame: CGRect(origin: .zero, size: CGSize(width: w, height: 16)))
        case .hParamsPat:
            h = HealthParamsCVCell.getHeight()
        case .otherSection:
            return OtherSectionEnum.sizeForItemAt(indexPath, collectionView: collectionView, layout: layout)
        default:
            w = w - collectionView.standart16Inset
        }
        w < 0 ? w = 0 : pass
        h < 0 ? h = 0 : pass
        return CGSize(width: w, height: h)
    }
    
    static func minimumInteritemSpacingForSectionAt(section: Int, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        switch PatientPStructEnum.allCases[safe: section] {
        case .otherSection:
            return OtherSectionEnum.minimumInteritemSpacingForSectionAt(section: section, collectionView: collectionView, layout: collectionViewLayout)
        default:
            return .zero
        }
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        switch PatientPStructEnum.allCases[safe: section] {
        case .generalInfoPat, .hParamsPat:
            return UIEdgeInsets(top: 0, left: 0, bottom: collectionView.standartInset, right: 0)
        case .otherSection:
            return OtherSectionEnum.insetForSectionAt(section, collectionView: collectionView)
        default:
            return .zero
        }
    }
     
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        switch PatientPStructEnum.allCases[safe: section] {
        case .otherSection:
            return OtherSectionEnum.minimumLineSpacingForSectionAt(section, collectionView: collectionView)
        default:
            return .zero
        }
    }
}
