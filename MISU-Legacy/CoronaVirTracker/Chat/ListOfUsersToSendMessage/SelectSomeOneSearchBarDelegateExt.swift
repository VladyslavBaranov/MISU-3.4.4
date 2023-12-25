//
//  SelectSomeOneSearchBarDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 05.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension SelectSomeOneToSendView: UISearchBarDelegate {
    func updateSearchResults(_ text: String) {
        if text.isEmpty {
            peoplesDataList = ListDHUSingleManager.shared.users + ListDHUSingleManager.shared.doctors
            listCollectionView.reloadData()
            return
        }
        
        var searchResult: [UserModel] = []
        
        let listToFilter = ListDHUSingleManager.shared.users + ListDHUSingleManager.shared.doctors
        searchResult = listToFilter.filter({ user -> Bool in
            let docName = user.doctor?.fullName?.lowercased() ?? ""
            let profName = user.profile?.name?.lowercased() ?? ""
            let workPost = user.doctor?.docPost?.name?.lowercased() ?? ""
            let hospName = user.doctor?.hospitalModel?.fullName?.lowercased() ?? ""
            return hospName.contains(text.lowercased()) || workPost.contains(text.lowercased()) ||
                docName.contains(text.lowercased()) || profName.contains(text.lowercased())
        })
        peoplesDataList = searchResult
        listCollectionView.reloadData()
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
