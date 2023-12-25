//
//  SelectSomeOneColectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 05.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - News UICollectionViewDelegate
extension SelectSomeOneToSendView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let isDoctor = peoplesDataList[safe: indexPath.item]?.profile == nil && peoplesDataList[safe: indexPath.item]?.doctor != nil
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CustomUsersCollectionViewCell else { return }
        
        if peoplesDataList[safe: indexPath.item]?.compare(with: selectedRecipient, isUserToText: true) ?? false {
            cell.isSelected(false)
            selectedRecipient = nil
        } else {
            selectedRecipient = (cell as? DoctorViewCell)?.doctorModel ?? (cell as? UserViewCell)?.userModel
            cell.isSelected(true)
        }
        
        collectionView.reloadData()
    }
}



// MARK: - Data Source
extension SelectSomeOneToSendView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peoplesDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch peoplesDataList[safe: indexPath.row]?.userType {
        case .doctor?:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.doctors.getItemDescription(), for: indexPath) as? DoctorViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DoctorViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.doctorModel = peoplesDataList[safe: indexPath.row]
            if cell.doctorModel?.compare(with: selectedRecipient, isUserToText: true) ?? false {
                cell.isSelected(true)
            } else {
                cell.isSelected(false)
            }
            return cell
        case .patient?:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.users.getItemDescription(), for: indexPath) as? UserViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DoctUserViewCellorViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.userModel = peoplesDataList[safe: indexPath.row]
            if cell.userModel?.compare(with: selectedRecipient, isUserToText: true) ?? false {
                cell.isSelected(true)
            } else {
                cell.isSelected(false)
            }
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
        }
    }
}



// MARK: - Flow Layout delegate
extension SelectSomeOneToSendView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width - standartInset*2
        var h: CGFloat = standartInset*2
        switch peoplesDataList[safe: indexPath.item]?.userType {
        case .doctor?:
            h = DoctorViewCell.getHeight()
        case .patient?:
            h = UserViewCell.getHeight()
        default:
            break
        }
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: standartInset, left: 0, bottom: standartInset, right: 0)
    }
}



// MARK: - Cells animation
//extension SelectSomeOneToSendView {
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let cell = collectionView.cellForItem(at: indexPath)
//
//        cell?.contentView.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1) { _ in
//            cell?.contentView.animateScaleTransform(x: 1, y: 1, duration: 0.1)
//        }
//
//        return true
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//
//        cell?.contentView.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//
//        cell?.contentView.animateScaleTransform(x: 1, y: 1, duration: 0.1)
//    }
//}

