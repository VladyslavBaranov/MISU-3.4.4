//
//  OtherSectionPSEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 10.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

public enum OtherSectionEnum: Int {
    case familyDoctor = 0
    case covidRisc = 1
    case analyzes = 2
    case illness = 3
    //case orderDrugs = 4
}

extension OtherSectionEnum: CustomEnumStruct {
    var cellClass: AnyClass {
        switch self {
        //case .symptoms:
            //return SymptomsCVCell.self
        case .covidRisc:
            return CovidRiscCVCell.self
        case .analyzes, .illness:
            return ImgLabelCVCell.self
        case .familyDoctor:
            return FamilyDoctorСVCell.self
        //case .orderDrugs:
            //return BuyDrugsCVCell.self
        //default:
            //return UICollectionViewCell.self
        }
    }
    
    static func didSelectItemAt<T>(_ indexPath: IndexPath, collectionView: UICollectionView, info: T?, completionAfterEdit: (() -> Void)?) {
        let user = info as? UserModel
        switch allCases[safe: indexPath.item] {
        case .familyDoctor:
            if let familyDoc = user?.profile?.getFamilyDoctorUserModel() {
                let vc = ProfileVC(familyDoc, isCurrent: false)
                collectionView.navigationController()?.pushViewController(vc, animated: true)
            } else if user?.isCurrent == true {
                let selectFamDocView = SelectFamilyDoctorView(frame: collectionView.controller()?.view.frame ?? .zero)
                selectFamDocView.show { _ in
                    (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
                }
            }
        //case .symptoms:
            //(collectionView.cellForItem(at: indexPath) as? SymptomsCVCell)?.goToEdit()
        case .covidRisc:
            (collectionView.cellForItem(at: indexPath) as? CovidRiscCVCell)?.passTestAction()
        case .analyzes:
            let nCurUser: UserModel? = user?.isCurrent == true ? nil : user
            let vc = SugarInsulinHistoryVC(selectedTab: .sugar, user: nCurUser)
            vc.hidesBottomBarWhenPushed = true
            collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
        case .illness:
            let vc = user?.isCurrent == true ? IllnessHistoryVC() : IllnessHistoryVC(user: user)
            vc.hidesBottomBarWhenPushed = true
            collectionView.controller()?.navigationController?.pushViewController(vc, animated: true)
        //case .orderDrugs:
            //(collectionView.cellForItem(at: indexPath) as? BuyDrugsCVCell)?.goToChat()
        default:
            return
        }
    }
    
    static func numberOfSections() -> Int {
        return 0
    }
    
    static func numberOfItemsInSection<T>(_ section: Int, info: T) -> Int {
        if (info as? UserModel)?.isCurrent == true {
            return allCases.count
        }
        return allCases.count
    }
    
    static func willDisplay<T>(_ cell: UICollectionViewCell, collectionView: UICollectionView, forItemAt indexPath: IndexPath, info: T?) {
        let user = info as? UserModel
        switch allCases[safe: indexPath.item] {
        case .analyzes:
            (cell as? ImgLabelCVCell)?.setImageAnd(title: NSLocalizedString("For diabetics", comment: ""),
                                                   image: UIImage(named: "analizesIcon"))
        case .illness:
            (cell as? ImgLabelCVCell)?.setImageAnd(title: NSLocalizedString("Medical history", comment: ""),
                                                   image: UIImage(named: "ilnessHistoryIcon"))
        case .familyDoctor:
            (cell as? FamilyDoctorСVCell)?.doctorModel = user?.profile?.getFamilyDoctorUserModel()
            (cell as? FamilyDoctorСVCell)?.isCurent = user?.isCurrent
        //case .symptoms:
            //(cell as? SymptomsCVCell)?.userModel = info as? UserModel
        case .covidRisc:
            (cell as? CovidRiscCVCell)?.pId = user?.isCurrent == true ? nil : user?.profile?.id
            (cell as? CovidRiscCVCell)?.getInfo()
        default:
            break
        }
    }
    
    static func sizeForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, layout: UICollectionViewLayout) -> CGSize {
        var w = collectionView.frame.width - collectionView.standartInset
        var h = collectionView.standartInset
        
        switch allCases[safe: indexPath.item] {
        case .analyzes:
            h = ImgLabelCVCell.getHeight(frame: collectionView.frame)
            w = (w - collectionView.standart16Inset)*80/169
        case .familyDoctor:
            h = FamilyDoctorСVCell.getHeight()
            w = (w - collectionView.standart16Inset)*80/169
        //case .symptoms:
        case .covidRisc:
            h = FamilyDoctorСVCell.getHeight()
            w = (w - collectionView.standart16Inset)*89/169
            break
        case .illness:
            h = ImgLabelCVCell.getHeight(frame: collectionView.frame)
            w = (w - collectionView.standart16Inset)*89/169
        //case .orderDrugs:
            //h = BuyDrugsCVCell.getHeight()
        default:
            break
        }
        
        w < 0 ? w = 0 : pass
        h < 0 ? h = 0 : pass
        return CGSize(width: w, height: h)
    }
    
    static func minimumInteritemSpacingForSectionAt(section: Int, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        return collectionView.standartInset
    }
    
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets {
        let const = collectionView.standartInset/2
        return UIEdgeInsets(top: 0, left: const, bottom: collectionView.standartInset, right: const)
    }
    
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat {
        return collectionView.standartInset
    }
}
