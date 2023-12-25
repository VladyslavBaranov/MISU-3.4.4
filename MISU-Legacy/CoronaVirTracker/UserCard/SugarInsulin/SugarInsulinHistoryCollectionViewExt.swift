//
//  SugarInsulinHistoryCollectionViewExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - UICollectionViewDelegate
extension SugarInsulinHistoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SugarInsulineEnum.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = view.frame.width
        let h = collectionView.safeAreaLayoutGuide.layoutFrame.height
        return CGSize(width: w, height: h)
    }
}



// MARK: - Layout delegate
extension SugarInsulinHistoryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SugarInsulineEnum.sugar.rawValue, for: indexPath) as? ParamHistoryViewCell else {
            BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not ParamHistoryViewCell \(indexPath)...")
            return UICollectionViewCell()
        }
        
        cell.listType = SugarInsulineEnum.allCases[indexPath.section]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ParamHistoryViewCell)?.paramsList = (cell as? ParamHistoryViewCell)?.listType == .sugar ? sugarDataList : insulinDataList
    }
}
