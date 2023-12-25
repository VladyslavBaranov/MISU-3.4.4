//
//  SymptomsPatientCollectionViewExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - UICollectionView Delegate
extension SymptomsPatientViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !(userModel?.isCurrent ?? false) { return }
        let frameForEdits = collectionView.controller()?.view.frame ?? .zero
        let editView = SymptomsPatientEditView(frame: frameForEdits)
        editView.show { _ in
            (collectionView.controller() as? ProfileVC)?.reloadUserProfile(request: false)
        }
    }
}



// MARK: - Data Source
extension SymptomsPatientViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (userModel?.isCurrent ?? false), symptomsData.count == 0 {
            return 1
        }
        return symptomsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (userModel?.isCurrent ?? false), symptomsData.count == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: editCellId, for: indexPath) as? EditSymptomsViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not EditSymptomsViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatientProfStructEnum.symptoms.key, for: indexPath) as? SymptomViewCell else {
            BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not SymptomViewCell \(indexPath)...")
            return UICollectionViewCell()
        }
        cell.title = symptomsData[safe: indexPath.item]
        return cell
    }
}



// MARK: - Flow Layout delegate
extension SymptomsPatientViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let symptom: String = NSLocalizedString(symptomsData[safe: indexPath.item] ?? "Title", comment: "")
        var w: CGFloat = SymptomViewCell.getWidth(symptom)
        let h: CGFloat = SymptomViewCell.getHeight()
        
        if (userModel?.isCurrent ?? false), symptomsData.count == 0 {
            w = EditSymptomsViewCell.getWidth()
        }
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: standartInset, bottom: 0, right: standartInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset/2
    }
}



// MARK: - Cells animation
extension SymptomsPatientViewCell {
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
