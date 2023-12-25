//
//  HospitalSelectView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Parameters
class HospitalSelectView: UICustomPresentViewController {
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.searchBarStyle = .minimal
        sb.backgroundColor = UIColor.appDefault.lightGrey
        sb.enablesReturnKeyAutomatically = true
        sb.placeholder = NSLocalizedString("Search", comment: "")
        sb.sizeToFit()
        return sb
    }()
    
    let hospitalsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = true
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        return cv
    }()
    
    var tempWhileSearchDataList: [HospitalModel] = []
    var hospitalsDataList: [HospitalModel] = []
    var selectedHospital: HospitalModel?
    var hospitalsListMode: HospitalListModelT = ListDHUSingleManager.shared.hospitalsList
}



// MARK: - Overrides
extension HospitalSelectView {
    override func setUpAdditionalViews() {
        self.titleLabel.text = NSLocalizedString("Hospitals", comment: "")
        prepareDoctorsList()
        setUpSearchBar()
        setUpTableView()
    }
    
    override func saveAction() -> Bool {
        if !(UCardSingleManager.shared.user.doctor?.hospitalModel?.compare(with: selectedHospital) ?? false) {
            let old = UCardSingleManager.shared.user
            UCardSingleManager.shared.user.doctor?.hospitalModel = selectedHospital
            UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                if success { DispatchQueue.main.async { self.completionAction?(true) } }
            }
        }
        return true
    }
}



// MARK: - List Data Controll
extension HospitalSelectView: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return contentView.getAddress()
    }
    
    func prepareDoctorsList() {
        if hospitalsListMode.searchWord != nil {
            getHospitalsBySearch()
            return
        }
        
        ListDHUSingleManager.shared.getHospitalsList(hospitalsListMode) { [self] newHospList in
            let pre = hospitalsListMode.list.count
            let after = newHospList.list.count
            hospitalsListMode = newHospList
            hospitalsDataList = newHospList.list
            DispatchQueue.main.async {
                hospitalsCollectionView.insertCells(preCount: pre, afterCount: after)
            }
        }
    }
    
    func getHospitalsBySearch() {
        if hospitalsListMode.currentPage == hospitalsListMode.pages, hospitalsListMode.currentPage != 0 { return }
        
        prepareViewsBeforReqest(viewsToBlock: [], activityView: hospitalsCollectionView)
        HospitalsManager.shared.search(hospitalsListMode) { [self] (hospLM, errorOp) in
            enableViewsAfterReqest()
            if let newHospList = hospLM {
                print("Get search hosp Success: \(newHospList)")
                let pre = hospitalsListMode.list.count
                let after = newHospList.list.count
                hospitalsListMode = newHospList
                hospitalsDataList = newHospList.list
                DispatchQueue.main.async {
                    hospitalsCollectionView.insertCells(preCount: pre, afterCount: after)
                }
            }
            
            if let er = errorOp {
                print("Get search hosp Error: \(hospitalsListMode.currentPage + 1) \(hospitalsListMode.searchWord ?? "nil") \(er)")
            }
        }
    }
}



// MARK: - SetUps
extension HospitalSelectView {
    private func setUpSearchBar() {
        contentView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    private func setUpTableView() {
        contentView.addSubview(hospitalsCollectionView)
        hospitalsCollectionView.delegate = self
        hospitalsCollectionView.dataSource = self
        hospitalsCollectionView.register(HospitalViewCell.self, forCellWithReuseIdentifier: ListStructEnum.hospitals.getItemDescription())
        hospitalsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        hospitalsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        hospitalsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        hospitalsCollectionView.heightAnchor.constraint(equalToConstant: self.frame.size.height*0.8).isActive = true
        hospitalsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
