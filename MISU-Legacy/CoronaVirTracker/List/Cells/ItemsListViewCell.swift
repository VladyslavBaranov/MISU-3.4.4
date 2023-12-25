//
//  ItemsListViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

class ItemsListViewCell: UICollectionViewCell {
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
    
    let scrollUpButton: UIButton = .createCustom(withImage: UIImage(named: "arrowIconUp")?.scaleTo(24),
                                              backgroundColor: UIColor.appDefault.white,
                                              contentEdgeInsets: .init(top: 6, left: 6, bottom: 6, right: 6),
                                              imageRenderingMode: .alwaysOriginal, shadow: true)
    
    var doctorsDataList: [UserModel] = []
    var hospitalsDataList: [HospitalModel] = []
    var usersDataList: [UserModel] = []
    
    var hospitalsListMode: HospitalListModelT = ListDHUSingleManager.shared.hospitalsList
    
    var doctorsListNotSorted: [UserModel] = []
    var hospitalsListNotSorted: [HospitalModel] = []
    var usersListNotSorted: [UserModel] = []
    
    var selectedCity: String? {
        get {
            print("Get City: \(userDefaultKey)")
            return UserDefaultsUtils.getString(key: userDefaultKey)}
        set(newValue) {
            print("Set City: \(newValue ?? "nil") \(userDefaultKey)")
            UserDefaultsUtils.save(value: newValue ?? "", key: userDefaultKey)
            if listType == .hospitals {
                updateCollectionData(.hospitals)
            }
        }
    }
    
    let userDefaultKeyBase: String = "selectedCity@thParams#en42aokd$spkasldlm%^&e1jio"
    var userDefaultKey: String = "selectedCity@thParams#en42aokd$spkasldlm%^&e1jio"
    
    var listType: ListStructEnum? {
        didSet {
            guard let type = listType else { return }
            userDefaultKey = userDefaultKeyBase + "\(type.rawValue)"
            updateCollectionData(type)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCollectionView()
        
//        HospitalsManager.shared.getAllHospitals(HospitalListModel()) { (_hospList, _error) in
//            print("### hosp S \(String(describing: _hospList))")
//            print("### hosp E \(String(describing: _error))")
//        }
    }
    
    func setUpCollectionView() {
        contentView.addSubview(itemsCollectionView)
        contentView.addSubview(scrollUpButton)
        contentView.bringSubviewToFront(scrollUpButton)
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        
        itemsCollectionView.register(DoctorViewCell.self, forCellWithReuseIdentifier: ListStructEnum.doctors.getItemDescription())
        itemsCollectionView.register(HospitalViewCell.self, forCellWithReuseIdentifier: ListStructEnum.hospitals.getItemDescription())
        itemsCollectionView.register(UserViewCell.self, forCellWithReuseIdentifier: ListStructEnum.users.getItemDescription())
        
        itemsCollectionView.register(CitiesListViewCell.self, forCellWithReuseIdentifier: CitiesListViewCell.doctorCityCellId)
        itemsCollectionView.register(CitiesListViewCell.self, forCellWithReuseIdentifier: CitiesListViewCell.hospitalCityCellId)
        itemsCollectionView.register(CitiesListViewCell.self, forCellWithReuseIdentifier: CitiesListViewCell.userCityCellId)
        
        itemsCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        itemsCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        itemsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        itemsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        scrollUpButton.trailingAnchor.constraint(equalTo: itemsCollectionView.trailingAnchor, constant: -standart24Inset).isActive = true
        scrollUpButton.bottomAnchor.constraint(equalTo: itemsCollectionView.bottomAnchor, constant: -standart24Inset).isActive = true
        scrollUpButton.widthAnchor.constraint(equalToConstant: standart24Inset*2).isActive = true
        scrollUpButton.heightAnchor.constraint(equalToConstant: standart24Inset*2).isActive = true
        scrollUpButton.addTarget(self, action: #selector(scrollUpButtonAction), for: .touchUpInside)
        scrollUpButton.animateFade(duration: 0.1)
    }
    
    @objc func scrollUpButtonAction() {
        itemsCollectionView.scrollToTop()
    }
    
    func updateCollectionData(_ type: ListStructEnum) {
        switch type {
        case .doctors:
            doctorsListNotSorted = ListDHUSingleManager.shared.doctors
        case .hospitals:
            var isInsert: Bool = true
            //hospitalsListNotSorted = ListDHUSingleManager.shared.hospitals
            //if let sCity = selectedCity, !sCity.isEmpty, sCity != "All", sCity != hospitalsListMode.city {
            //print("### U H \(selectedCity ?? "nil")")
            let sCity = selectedCity == "All" ? nil : selectedCity
            if sCity != hospitalsListMode.city {
                hospitalsListMode = .init()
                hospitalsListMode.city = sCity
                isInsert = false
                //print("### U H \(sCity ?? "nil") \(isInsert)")
            }
            ListDHUSingleManager.shared.getHospitalsList(hospitalsListMode) { [self] newHospList in
                //print("### HOSPL \(newHospList.list.count)")
                let pre = hospitalsListMode.list.count
                let after = newHospList.list.count
                hospitalsListMode = newHospList
                hospitalsDataList = newHospList.list
                DispatchQueue.main.async {
                    //print("### U H \(isInsert)")
                    //print("### U H \(pre) \(after)")
                    if isInsert {
                        itemsCollectionView.insertCells(preCount: pre, afterCount: after, section: ListWithSortEnum.data.rawValue)
                    } else {
                        itemsCollectionView.reloadSections([ListWithSortEnum.data.rawValue])
                        //itemsCollectionView.reloadData()
                    }
                }
            }
            return
        case .users:
            usersListNotSorted = ListDHUSingleManager.shared.users
        }
        
        citySelected(selectedCity)
        
        //print(type)
        
        itemsCollectionView.reloadData()
    }
    
    func citySelected(_ cityOp: String? = nil) {
        if let city = cityOp, !city.isEmpty, city != "All" {
            doctorsDataList = []
            hospitalsDataList = []
            usersDataList = []
            
            doctorsListNotSorted.forEach({ if $0.location?.city == city {doctorsDataList.append($0)} })
            //hospitalsListNotSorted.forEach({ if $0.location?.city == city {hospitalsDataList.append($0)} })
            usersListNotSorted.forEach({ if $0.location?.city == city {usersDataList.append($0)} })
        } else {
            doctorsDataList = doctorsListNotSorted
            //hospitalsDataList = hospitalsListNotSorted
            usersDataList = usersListNotSorted
        }
        
        switch listType {
        case .hospitals: break
            //itemsCollectionView.reloadSections([ListWithSortEnum.data.rawValue])
        default:
            itemsCollectionView.reloadData()
        }
        
        selectedCity = cityOp
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            ListDHUSingleManager.shared.updateData {
                DispatchQueue.main.async {
                    guard let type = self.listType else { return }
                    self.updateCollectionData(type)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > standart24Inset*2 {
            scrollUpButton.animateShow(duration: 0.1)
        }
        if scrollView.contentOffset.y <= 0 {
            scrollUpButton.animateFade(duration: 0.1)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
