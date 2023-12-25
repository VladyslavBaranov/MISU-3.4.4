//
//  ItemsListCollectionViewExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 08.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

enum ListWithSortEnum: Int, CaseIterable {
    case cities = 0
    case data = 1
}

// MARK: - News UICollectionViewDelegate
extension ItemsListViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch listType {
        case .hospitals:
            return ListWithSortEnum.allCases.count
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch listType {
        case .doctors?:
            return doctorsDataList.count
        case .hospitals?:
            if ListWithSortEnum.allCases[safe: section] == .cities {
                return 1
            }
            return hospitalsDataList.count
        case .users?:
            return usersDataList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w = collectionView.frame.width - standartInset*2
        var h: CGFloat = standartInset*5
        
        switch listType {
        case .doctors?:
            h = DoctorViewCell.getHeight()
        case .hospitals?:
            if indexPath.section == ListWithSortEnum.cities.rawValue {
                h = SymptomViewCell.getHeight()+collectionView.standartInset/2
                w = collectionView.frame.width
                return CGSize(width: w, height: h)
            }
            h = HospitalViewCell.getHeight()
        case .users?:
            h = UserViewCell.getHeight()
        default:
            break
        }
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //if indexPath.section == ListWithSortEnum.cities.rawValue { return }
        switch listType {
        case .doctors?:
            let vc = ProfileVC()
            vc.setUser(doctorsDataList[safe: indexPath.row], isCurrent: false)
            navigationController()?.pushViewController(vc, animated: true)
            return
        case .hospitals?:
            let vc = HospitalVC()
            vc.hospital = hospitalsDataList[safe: indexPath.row]
            navigationController()?.pushViewController(vc, animated: true)
            return
        case .users?:
            let vc = ProfileVC()
            vc.setUser(usersDataList[safe: indexPath.row], isCurrent: false)
            navigationController()?.pushViewController(vc, animated: true)
            return
        default:
            return
        }
    }
}



// MARK: - Layout delegate
extension ItemsListViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch listType {
        case .doctors?:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.doctors.getItemDescription(), for: indexPath) as? DoctorViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not DoctorViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.doctorModel = doctorsDataList[safe: indexPath.row]
            return cell
            
        case .hospitals?:
            if indexPath.section == ListWithSortEnum.cities.rawValue {
                //var cities: [String] = []
                let cellId: String = CitiesListViewCell.hospitalCityCellId
                //hospitalsListNotSorted.forEach({ if let ct = $0.location?.city, cities.first(where: {$0 == ct}) == nil {cities.append(ct)} })
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? CitiesListViewCell else {
                    BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not CitiesListViewCell \(indexPath)...")
                    return UICollectionViewCell()
                }
                
                //cell.citiesList = cities
                cell.selectedCity = selectedCity
                cell.listType = listType
                return cell
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.hospitals.getItemDescription(), for: indexPath) as? HospitalViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not HospitalViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            //cell.hospitalModel = hospitalsDataList[safe: indexPath.row]
            cell.hospitalModel = nil
            if hospitalsDataList.count-1 == indexPath.item {
                updateCollectionData(.hospitals)
            }
            return cell
        case .users?:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListStructEnum.users.getItemDescription(), for: indexPath) as? UserViewCell else {
                BeautifulOutputer.cPrint(type: .warning, place: .newsView, message1: "Cell is not UserViewCell \(indexPath)...")
                return UICollectionViewCell()
            }
            cell.userModel = usersDataList[safe: indexPath.row]
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellH = cell as? HospitalViewCell else { return }
        cellH.hospitalModel = hospitalsDataList[safe: indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == ListWithSortEnum.cities.rawValue {
            return UIEdgeInsets(top: standartInset, left: 0, bottom: 0, right: 0)
        }
        //if section == ListWithSortEnum.cities.rawValue { return .zero}
        return UIEdgeInsets(top: standartInset, left: 0, bottom: collectionView.standartInset, right: 0)
    }
}



// MARK: - Cells animation
extension ItemsListViewCell {
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

