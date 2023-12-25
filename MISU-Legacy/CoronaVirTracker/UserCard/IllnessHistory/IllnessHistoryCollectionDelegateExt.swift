//
//  IllnessHistoryCollectionDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 08.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - News UICollectionViewDelegate
extension IllnessHistoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? IllnessViewCell,
              (userModel?.isCurrent ?? true) else { return }
        
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
//        if getStateBySection(indexPath.section) != .cured {
//            let curedAction = UIAlertAction(title: NSLocalizedString("Recuperate", comment: ""), style: .default, handler: { _ in
//            })
//            curedAction.customTitleTextColor = UIColor.appDefault.green
//            menuController.addAction(curedAction)
//        }
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default, handler: { _ in
            self.updateIllness(illness: cell.illnessModel)
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { _ in
            self.deleteIllness(illness: cell.illnessModel)
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = cell
        present(menuController, animated: true)
        //cell.illnessModel
    }
    
    func getStateBySection(_ section: Int) -> IllnessStateEnum {
        switch section {
        case 0:
            return .ill
        case 1:
            return .chronic
        default:
            return .cured
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedByStateDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //guard let state = IllnessStateEnum.allCases[safe: section] else { return 0 }
        let state = getStateBySection(section)
        return sortedByStateDataList[state]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = collectionView.frame.width - collectionView.standartInset*2
        let h: CGFloat = IllnessViewCell.getHeight()
        return CGSize(width: w, height: h)
    }
}



// MARK: - Layout delegate
extension IllnessHistoryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customIllnesCellId, for: indexPath) as? IllnessViewCell else {
            return UICollectionViewCell()
        }
        //guard var state = IllnessStateEnum.allCases[safe: indexPath.section] else { return cell }
        let state = getStateBySection(indexPath.section)
        cell.illnessModel = sortedByStateDataList[state]?[safe: indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch getStateBySection(section) {
        case .cured:
            return UIEdgeInsets(top: collectionView.standartInset*1.5, left: 0, bottom: collectionView.standartInset*1.5, right: 0)
        default:
            return UIEdgeInsets(top: collectionView.standartInset*1.5, left: 0, bottom: 0, right: 0)
        }
    }
}



// MARK: - Cells animation
extension IllnessHistoryVC {
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

