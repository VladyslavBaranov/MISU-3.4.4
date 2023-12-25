//
//  CitiesListCollectionDelegate.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension SortingColVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        lastSelectItemIndexPath = indexPath
        switch PatientsVCStructEnum.SortingSEnum.allCases[indexPath.item] {
        case .state:
            let optionItemListVC = StatePopoverView()
            optionItemListVC.popoverPresentationController?.sourceView = cell
            optionItemListVC.popoverPresentationController?.delegate = self
            self.controller()?.present(optionItemListVC, animated: true, completion: nil)
            return
        case .temperature:
            PatientsVCStructEnum.isAscending = !(PatientsVCStructEnum.isAscending ?? false)
            PatientsVCStructEnum.patientsSortingDelegate?.temperatureOrderChanged(PatientsVCStructEnum.isAscending)
            collectionView.reloadItems(at: [indexPath])
        case .symptoms:
            let optionItemListVC = SymptomsPopoverView()
            optionItemListVC.popoverPresentationController?.sourceView = cell
            optionItemListVC.popoverPresentationController?.delegate = self
            self.controller()?.present(optionItemListVC, animated: true, completion: nil)
        }
    }
}

extension SortingColVCell: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        itemsCollectionView.reloadItems(at: [lastSelectItemIndexPath])
        //PatientsVCStructEnum.patientsSortingDelegate?.statesChanged(PatientsVCStructEnum.selectedStates)
        //print(PatientsVCStructEnum.selectedStates)
    }
}



// MARK: - Data Source
extension SortingColVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PatientsVCStructEnum.SortingSEnum.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let reuseId = PatientsVCStructEnum.SortingSEnum.allCases[safe: indexPath.item]?.key else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: indexPath)
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? SymptomViewCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: indexPath)
        }
        cell.title = PatientsVCStructEnum.SortingSEnum.allCases[safe: indexPath.item]?.title
        cell.image = PatientsVCStructEnum.SortingSEnum.allCases[safe: indexPath.item]?.image
        cell.titleLabel.textColor = .black
        return cell
    }
}



// MARK: - Flow Layout delegate
extension SortingColVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sortTitle: String = PatientsVCStructEnum.SortingSEnum.allCases[safe: indexPath.item]?.title ?? ""
        let isImage = PatientsVCStructEnum.SortingSEnum.allCases[safe: indexPath.item]?.image != nil
        let w: CGFloat = SymptomViewCell.getWidth(sortTitle, image: isImage)
        let h: CGFloat = SymptomViewCell.getHeight()
        
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
extension SortingColVCell {
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
