//
//  ParamHistoryCollectionViewExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - News UICollectionViewDelegate
extension ParamHistoryViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paramsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width - standartInset*2
        let h: CGFloat = DocNeedsCell.getHeight()
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



// MARK: - Layout delegate
extension ParamHistoryViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SugarInsulineEnum.insuline.rawValue, for: indexPath) as? DocNeedsCell else {
            BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DoctorViewCell \(indexPath)...")
            return UICollectionViewCell()
        }
        cell.paramValue = paramsList[safe: indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: standartInset, left: 0, bottom: collectionView.standartInset, right: 0)
    }
}



// MARK: - Cells animation
extension ParamHistoryViewCell {
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

