//
//  SelectFamilyDoctorView.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/12/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Parameters
class SelectFamilyDoctorView: UICustomPresentViewController {
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
    
    let doctorsCollectionView: UICollectionView = {
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
    
    var doctorsDataList: [UserModel] = []
    var selectedDoctor: UserModel?
}



// MARK: - Overrides
extension SelectFamilyDoctorView {
    override func setUpAdditionalViews() {
        self.titleLabel.text = NSLocalizedString("Family Doctors", comment: "")
        prepareDoctorsList()
        setUpSearchBar()
        setUpTableView()
    }
    
    override func saveAction() -> Bool {
        if !(UCardSingleManager.shared.user.profile?.getFamilyDoctorUserModel()?.compare(with: selectedDoctor, isFamDoc: true) ?? false) {
            let old = UCardSingleManager.shared.user
            UCardSingleManager.shared.user.profile?.familyDoctor = selectedDoctor?.doctor
            UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                if success { DispatchQueue.main.async { self.completionAction?(true) } }
            }
        }
        return true
    }
}



// MARK: - List Data Controll
extension SelectFamilyDoctorView {
    func prepareDoctorsList() {
        doctorsDataList = ListDHUSingleManager.shared.familyDoctors
        ListDHUSingleManager.shared.updateData {
            self.doctorsDataList = ListDHUSingleManager.shared.doctors
            DispatchQueue.main.async { self.doctorsCollectionView.reloadData() }
        }
        selectedDoctor = UCardSingleManager.shared.user.profile?.getFamilyDoctorUserModel()
    }
}



// MARK: - SetUps
extension SelectFamilyDoctorView {
    private func setUpSearchBar() {
        contentView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    private func setUpTableView() {
        contentView.addSubview(doctorsCollectionView)
        doctorsCollectionView.delegate = self
        doctorsCollectionView.dataSource = self
        doctorsCollectionView.register(DoctorViewCell.self, forCellWithReuseIdentifier: ListStructEnum.doctors.getItemDescription())
        doctorsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        doctorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        doctorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        doctorsCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height*0.8).isActive = true
        doctorsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
