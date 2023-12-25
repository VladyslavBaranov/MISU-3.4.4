//
//  PatientVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 10.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class PatientsVC: UIViewController {
    let itemsCollectionView: UICollectionView = {
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
    
    var usersDataList: [UserModel] = []
    var usersListNotSorted: [UserModel] = []
    var usersDataListFildered: [UserModel] {
        get {
            var sortedState: [UserModel] = usersListNotSorted
            if PatientsVCStructEnum.selectedStates.count > 0 {
                sortedState = usersListNotSorted.filter { user -> Bool in
                    if PatientsVCStructEnum.selectedStates.firstIndex(of: user.profile?.status?.new ?? .well) != nil {
                        return true
                    }
                    return false
                }
            }
            
            var sympSorted = sortedState
            if PatientsVCStructEnum.selectedSympthoms.count > 0 {
                sympSorted = sortedState.filter { user -> Bool in
                    guard let sympts = user.profile?.symptoms else { return false }
                    var isSymp = false
                    sympts.forEach { symp in
                        if PatientsVCStructEnum.selectedSympthoms.firstIndex(of: symp) != nil {
                            isSymp = true
                        }
                    }
                    return isSymp
                }
            }
            
            return sympSorted
        }
    }
}



// MARK:- View Loads override
extension PatientsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
        setUpNavigationView()
        setUpSubViews()
        setUpCollectionView()
        PatientsVCStructEnum.patientsSortingDelegate = self
        updateCollectionData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ListDHUTaskSingletonManager.shared.doTask(listVC: self)
    }
}



// MARK: - Actions
extension PatientsVC {
    func updateCollectionData() {
        usersListNotSorted = ListDHUSingleManager.shared.users
        usersDataList = usersDataListFildered
        reloadListSection()
        temperatureOrderChanged(PatientsVCStructEnum.isAscending)
        
        itemsCollectionView.reloadData()
    }
}



extension PatientsVC: PatientsListSortingDelegate {
    func statesChanged(_ states: [HealthStatusEnum]) {
        usersDataList = usersDataListFildered
        reloadListSection()
        temperatureOrderChanged(PatientsVCStructEnum.isAscending)
    }
    
    func temperatureOrderChanged(_ isAscending: Bool?) {
        guard let isAsc = isAscending else { return }
        usersDataList.sort { (first, second) -> Bool in
            guard let fTemp = first.profile?.temperature else { return false }
            guard let sTemp = second.profile?.temperature else { return true }
            
            if fTemp > sTemp {
                return isAsc
            }
            return !isAsc
        }
        reloadListSection()
    }
    
    func sympthomsChanged(_ sympthoms: [String]) {
        usersDataList = usersDataListFildered
        reloadListSection()
        temperatureOrderChanged(PatientsVCStructEnum.isAscending)
    }
    
    func reloadListSection() {
        itemsCollectionView.reloadSections([PatientsVCStructEnum.list.rawValue])
    }
}



// MARK: - Scroll view overloads
extension PatientsVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            ListDHUSingleManager.shared.updateData {
                DispatchQueue.main.async {
                    self.updateCollectionData()
                }
            }
        }
    }
}



// MARK: - View Setups
extension PatientsVC {
    func setUpCollectionView() {
        view.addSubview(itemsCollectionView)
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        itemsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Test")
        itemsCollectionView.register(UserViewCell.self, forCellWithReuseIdentifier: PatientsVCStructEnum.list.key)
        itemsCollectionView.register(SortingColVCell.self, forCellWithReuseIdentifier: PatientsVCStructEnum.sorting.key)
        
        itemsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        itemsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        itemsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setUpSubViews() {
        
    }
    
    func viewSetUp() {
        view.backgroundColor = UIColor.appDefault.lightGrey
    }

    func setUpNavigationView() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

