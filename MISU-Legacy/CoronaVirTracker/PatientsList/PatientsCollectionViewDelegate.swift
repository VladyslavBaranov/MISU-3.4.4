//
//  PatientsCollectionViewDelegate.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension PatientsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return PatientsVCStructEnum.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch PatientsVCStructEnum.allCases[safe: section] {
        case .sorting:
            return 1
        case .list:
            return usersDataList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w = collectionView.frame.width - view.standartInset*2
        var h: CGFloat = view.standartInset*5
        
        switch PatientsVCStructEnum.allCases[safe: indexPath.section] {
        case .sorting:
            h = SymptomViewCell.getHeight() + collectionView.standartInset
            w = collectionView.frame.width
        case .list:
            h = UserViewCell.getHeight()
        default:
            break
        }
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch PatientsVCStructEnum.allCases[safe: indexPath.section] {
        case .list:
            let vc = ProfileVC()
            vc.setUser(usersDataList[safe: indexPath.row], isCurrent: false)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            return
        default:
            return
        }
    }
}



// MARK: - Layout delegate
extension PatientsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch PatientsVCStructEnum.allCases[safe: indexPath.section] {
        case .sorting:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatientsVCStructEnum.sorting.key, for: indexPath) as? SortingColVCell else {
                break
            }
            return cell
        case .list:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatientsVCStructEnum.list.key, for: indexPath) as? UserViewCell else {
                break
            }
            cell.userModel = usersDataList[safe: indexPath.row]
            return cell
        default:
            break
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch PatientsVCStructEnum.allCases[safe: section] {
        case .sorting:
            return UIEdgeInsets(top: view.standartInset, left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets(top: view.standartInset, left: 0, bottom: view.standartInset, right: 0)
        }
    }
}



// MARK: - Cells animation
extension PatientsVC {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1) { _ in
            cell?.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
               
        cell?.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
               
        cell?.animateScaleTransform(x: 1, y: 1, duration: 0.1)
    }
}

