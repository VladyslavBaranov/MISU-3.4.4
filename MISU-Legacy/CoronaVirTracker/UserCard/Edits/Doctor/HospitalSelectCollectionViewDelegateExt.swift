//
//  HospitalSelectCollectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - News UICollectionViewDelegate
extension HospitalSelectView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? HospitalViewCell else { return }
        if hospitalsDataList[safe: indexPath.item]?.compare(with: selectedHospital) ?? false {
            cell.isSelected(false)
            selectedHospital = nil
        } else {
            selectedHospital = cell.hospitalModel
            cell.isSelected(true)
        }
        
        cell.removeAllAnimations()
        collectionView.reloadData()
    }
}



// MARK: - Data Source
extension HospitalSelectView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hospitalsDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.hospitals.getItemDescription(), for: indexPath) as? HospitalViewCell else { return UICollectionViewCell() }
        cell.hospitalModel = nil//hospitalsDataList[safe: indexPath.row]
        /*
        if cell.hospitalModel?.compare(with: selectedHospital) ?? false {
            cell.isSelected(true)
        } else {
            cell.isSelected(false)
        }*/
        if hospitalsDataList.count-1 == indexPath.item {
            prepareDoctorsList()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let hCell = cell as? HospitalViewCell else { return }
        hCell.hospitalModel = hospitalsDataList[safe: indexPath.row]
        
        if hCell.hospitalModel?.compare(with: selectedHospital) ?? false {
            hCell.isSelected(true)
        } else {
            hCell.isSelected(false)
        }
    }
}



// MARK: - Flow Layout delegate
extension HospitalSelectView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width - standartInset*2
        var h: CGFloat = standartInset*2
        h = HospitalViewCell.getHeight()
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
//extension HospitalSelectView {
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.contentView.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1) { _ in
//            cell?.contentView.animateScaleTransform(x: 1, y: 1, duration: 0.1)
//        }
//        return true
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.contentView.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.contentView.animateScaleTransform(x: 1, y: 1, duration: 0.1)
//    }
//}

