//
//  SortingColVCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SortingColVCell: UICollectionViewCell {
    let itemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = true
        cv.backgroundColor = .clear
        
        return cv
    }()
    
    var lastSelectItemIndexPath: IndexPath = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        contentView.addSubview(itemsCollectionView)
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        
        itemsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Test")
        PatientsVCStructEnum.SortingSEnum.allCases.forEach { srt in
            itemsCollectionView.register(SymptomViewCell.self, forCellWithReuseIdentifier: srt.key)
        }
        
        itemsCollectionView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        itemsCollectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        itemsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        itemsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
