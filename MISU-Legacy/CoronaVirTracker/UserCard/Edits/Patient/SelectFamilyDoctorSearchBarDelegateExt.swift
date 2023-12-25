//
//  SelectFamilyDoctorSearchBarDelegateExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/13/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension SelectFamilyDoctorView: UISearchBarDelegate {
    func updateSearchResults(_ text: String) {
        if text.isEmpty {
            doctorsDataList = ListDHUSingleManager.shared.familyDoctors
            doctorsCollectionView.reloadData()
            return
        }
        
        var searchResult: [UserModel] = []
        
        searchResult = ListDHUSingleManager.shared.doctors.filter({ doctor -> Bool in
            let name = doctor.doctor?.fullName?.lowercased() ?? ""
            let workPost = doctor.doctor?.docPost?.name ?? ""
            let hospName = doctor.doctor?.hospitalModel?.fullName?.lowercased() ?? ""
            return hospName.contains(text.lowercased()) || workPost.contains(text.lowercased()) || name.contains(text.lowercased())
        })
        doctorsDataList = searchResult
        doctorsCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
}
