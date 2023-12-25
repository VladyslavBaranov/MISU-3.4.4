//
//  CitiesListCollectionDelegate.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension CitiesListViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SymptomViewCell else { return }
        if let selectedCell = collectionView.cellForItem(at: IndexPath(row: selectedCityIndex, section: ListWithSortEnum.cities.rawValue)) as? SymptomViewCell { selectedCell.isSelected(selectedCityIndex == indexPath.item) }
        
        cell.isSelected(true)
        selectedCityIndex = indexPath.item
        
        guard let itemsListCell: ItemsListViewCell? = collectionView.firstSuperviewOfType() else { return }
        itemsListCell?.citySelected(citiesListData[safe: selectedCityIndex])
    }
}



// MARK: - Data Source
extension CitiesListViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return citiesListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CitiesListViewCell.doctorCityCellId, for: indexPath) as? SymptomViewCell else {
            BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not SymptomViewCell \(indexPath)...")
            return UICollectionViewCell()
        }
//        cell.title = citiesListData[safe: indexPath.item]
        cell.isSelected(false)
//
        if citiesListData.count-1 == indexPath.item {
            updateCities()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SymptomViewCell else { return }
        cell.title = citiesListData[safe: indexPath.item]
        cell.isSelected(selectedCityIndex == indexPath.item)
    }
}



// MARK: - Flow Layout delegate
extension CitiesListViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let symptom: String = citiesListData[safe: indexPath.item] ?? "All"
        let w: CGFloat = SymptomViewCell.getWidth(symptom) + standartInset
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
extension CitiesListViewCell {
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
