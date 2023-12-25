//
//  HospitalCollectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 14.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - News UICollectionViewDelegate
extension HospitalVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HospitalStructEnum.didSelectItemAt(indexPath, collectionView: collectionView, info: hospital, completionAfterEdit: nil)
    }
}



// MARK: - Data Source
extension HospitalVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HospitalStructEnum.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HospitalStructEnum.numberOfItemsInSection(section, info: hospital)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        return HospitalStructEnum.willDisplay(cell, collectionView: collectionView, forItemAt: indexPath, info: hospital)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return HospitalStructEnum.cellForItemAt(indexPath, collectionView: collectionView)
    }
}



// MARK: - Flow Layout delegate
extension HospitalVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return HospitalStructEnum.defaultSizeForItemAt(indexPath, collectionView: collectionView, layout: collectionViewLayout)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return HospitalStructEnum.insetForSectionAt(section, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return HospitalStructEnum.minimumLineSpacingForSectionAt(section, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return HospitalStructEnum.minimumInteritemSpacingForSectionAt(section: section, collectionView: collectionView, layout: collectionViewLayout)
    }
}



// MARK: - Cells animation
extension HospitalVC {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return HospitalStructEnum.shouldSelectItemAt(indexPath, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        HospitalStructEnum.didHighlightItemAt(indexPath, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        HospitalStructEnum.didUnhighlightItemAt(indexPath, collectionView: collectionView)
    }
}
