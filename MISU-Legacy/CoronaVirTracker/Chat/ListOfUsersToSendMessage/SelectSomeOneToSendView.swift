//
//  SelectSomeOneToSendView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 05.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Parameters
class SelectSomeOneToSendView: UICustomPresentViewController {
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
    
    let listCollectionView: UICollectionView = {
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
    
    var peoplesDataList: [UserModel] = []
    var selectedRecipient: UserModel?
    private var completionSelected: ((UserModel) -> Void)?
}



// MARK: - Overrides
extension SelectSomeOneToSendView {
    override func setUpAdditionalViews() {
        self.titleLabel.text = NSLocalizedString("New message", comment: "")
        //doneButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        prepareDataList()
        setUpSearchBar()
        setUpTableView()
    }
    
    override func saveAction() -> Bool {
        if let user = selectedRecipient { completionSelected?(user) }
        return true
    }
}



// MARK: - List Data Controll
extension SelectSomeOneToSendView {
    func prepareDataList() {
        peoplesDataList = ListDHUSingleManager.shared.users + ListDHUSingleManager.shared.doctors
        ListDHUSingleManager.shared.updateData {
            self.peoplesDataList = ListDHUSingleManager.shared.users + ListDHUSingleManager.shared.doctors
            DispatchQueue.main.async { self.listCollectionView.reloadData() }
        }
    }
}



// MARK: - SetUps
extension SelectSomeOneToSendView {
    public func setUpCompletionSelected(completion: ((UserModel)->Void)?) {
        completionSelected = completion
    }
    
    private func setUpSearchBar() {
        contentView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    private func setUpTableView() {
        contentView.addSubview(listCollectionView)
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        listCollectionView.register(DoctorViewCell.self, forCellWithReuseIdentifier: ListStructEnum.doctors.getItemDescription())
        listCollectionView.register(UserViewCell.self, forCellWithReuseIdentifier: ListStructEnum.users.getItemDescription())
        
        listCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        listCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        listCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        listCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height*0.8).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
