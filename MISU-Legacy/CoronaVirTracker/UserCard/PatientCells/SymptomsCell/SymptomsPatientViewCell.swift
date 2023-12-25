//
//  SymptomsPatientViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SymptomsPatientViewCell: UICollectionViewCell {
    let symptomsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = true
        cv.backgroundColor = UIColor.appDefault.lightGrey
        
        return cv
    }()
    
    var userModel: UserModel? {
        didSet {
            guard let symp = userModel?.profile?.symptoms else { return }
            symptomsData = symp
            symptomsCollectionView.reloadData()
        }
    }
    
    var symptomsData: [String] = []
    
    let editCellId = "editCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        contentView.addSubview(symptomsCollectionView)
        
        symptomsCollectionView.delegate = self
        symptomsCollectionView.dataSource = self
        
        symptomsCollectionView.register(SymptomViewCell.self, forCellWithReuseIdentifier: PatientProfStructEnum.symptoms.key)
        symptomsCollectionView.register(EditSymptomsViewCell.self, forCellWithReuseIdentifier: editCellId)
        
        symptomsCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        symptomsCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        symptomsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        symptomsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
