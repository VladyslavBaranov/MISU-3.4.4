//
//  ProfileCollectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - UICollectionView Delegate
extension ProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //if !isCurrentUser { return }
        switch userModel?.userType {
        case .patient:
            PatientPStructEnum.didSelectItemAt(indexPath, collectionView: collectionView, info: userModel) {
                self.reloadUserProfile(request: false)
            }
            return
        case .doctor, .familyDoctor:
            DoctorPStructEnum.didSelectItemAt(indexPath, collectionView: collectionView, info: userModel) {
                self.reloadUserProfile(request: false)
            }
            return
        default:
            return
        }
    }
}



// MARK: - Data Source
extension ProfileVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.numberOfSections()
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.numberOfSections()
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.numberOfItemsInSection(section, info: userModel)
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.numberOfItemsInSection(section, info: userModel)
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.customCellForItemAt(indexPath, collectionView: collectionView)
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.cellForItemAt(indexPath, collectionView: collectionView)
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch userModel?.userType {
        case .patient:
            PatientPStructEnum.willDisplay(cell, collectionView: collectionView, forItemAt: indexPath, info: userModel)
        case .doctor, .familyDoctor:
            DoctorPStructEnum.willDisplay(cell, collectionView: collectionView, forItemAt: indexPath, info: userModel)
        default:
            return
        }
    }
}



// MARK: - Flow Layout delegate
extension ProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.sizeForItemAt(indexPath, collectionView: collectionView, layout: collectionViewLayout)
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.defaultSizeForItemAt(indexPath, collectionView: collectionView, layout: collectionViewLayout)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.insetForSectionAt(section, collectionView: collectionView)
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.insetForSectionAt(section, collectionView: collectionView)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.minimumLineSpacingForSectionAt(section, collectionView: collectionView)
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.minimumLineSpacingForSectionAt(section, collectionView: collectionView)
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch userModel?.userType {
        case .patient:
            return PatientPStructEnum.minimumInteritemSpacingForSectionAt(section: section, collectionView: collectionView, layout: collectionViewLayout)
        case .doctor, .familyDoctor:
            return DoctorPStructEnum.minimumInteritemSpacingForSectionAt(section: section, collectionView: collectionView, layout: collectionViewLayout)
        default:
            return .zero
        }
    }
}



// MARK: - Cells animation
extension ProfileVC {
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

