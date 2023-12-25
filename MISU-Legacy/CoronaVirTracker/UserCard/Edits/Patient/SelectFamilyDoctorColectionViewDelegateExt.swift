//
//  SelectFamilyDoctorColectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/13/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - News UICollectionViewDelegate
extension SelectFamilyDoctorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DoctorViewCell else { return }
        if doctorsDataList[safe: indexPath.item]?.compare(with: selectedDoctor, isFamDoc: true) ?? false {
            cell.isSelected(false)
            selectedDoctor = nil
        } else {
            selectedDoctor = cell.doctorModel
            cell.isSelected(true)
        }
        
        collectionView.reloadData()
    }
}



// MARK: - Data Source
extension SelectFamilyDoctorView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doctorsDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.doctors.getItemDescription(), for: indexPath) as? DoctorViewCell else {
            BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DoctorViewCell \(indexPath)...")
            return UICollectionViewCell()
        }
        cell.doctorModel = doctorsDataList[safe: indexPath.row]
        if cell.doctorModel?.compare(with: selectedDoctor, isFamDoc: true) ?? false {
            cell.isSelected(true)
        } else {
            cell.isSelected(false)
        }
        return cell
    }
}



// MARK: - Flow Layout delegate
extension SelectFamilyDoctorView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width - standartInset*2
        var h: CGFloat = standartInset*2
        h = DoctorViewCell.getHeight()
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
//extension SelectFamilyDoctorView {
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

