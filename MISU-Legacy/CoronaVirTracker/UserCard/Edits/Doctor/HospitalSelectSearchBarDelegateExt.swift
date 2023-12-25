//
//  HospitalSelectSearchBarDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension HospitalSelectView: UISearchBarDelegate {
    func updateSearchResults(_ text: String) {
        if text.isEmpty {
            hospitalsListMode = ListDHUSingleManager.shared.hospitalsList
            hospitalsDataList = hospitalsListMode.list
            hospitalsCollectionView.reloadData()
            return
        }
        
        hospitalsListMode = .init()
        hospitalsListMode.searchWord = text
        hospitalsDataList = []
        hospitalsCollectionView.reloadData()
        prepareDoctorsList()
        
        /*var searchResult: [HospitalModel] = []
        
        searchResult = ListDHUSingleManager.shared.hospitals.filter({ hospital -> Bool in
            let hospName = hospital.fullName?.lowercased() ?? ""
            let hospAddress = hospital.location?.getFullLocationStr().lowercased() ?? ""
            
            return hospName.contains(text.lowercased()) || hospAddress.contains(text.lowercased())
        })
        hospitalsDataList = searchResult
        hospitalsCollectionView.reloadData()*/
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

