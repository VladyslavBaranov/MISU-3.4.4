//
//  ListDHUCollectionViewExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - UICollectionViewDelegate
extension ListDHUVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfListSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = view.frame.width
        let h = view.safeAreaLayoutGuide.layoutFrame.height
        return CGSize(width: w, height: h)
    }
}



// MARK: - Layout delegate
extension ListDHUVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCellIds.additionalNews.rawValue, for: indexPath) as? ItemsListViewCell else {
            BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not ItemsListViewCell \(indexPath)...")
            return UICollectionViewCell()
        }
        
        switch indexPath.section {
        case ListStructEnum.doctors.rawValue:
            cell.listType = .doctors
        case ListStructEnum.hospitals.rawValue:
            cell.listType = .hospitals
        case ListStructEnum.users.rawValue:
            cell.listType = .users
        default:
            break
        }
        
        return cell
    }
}
