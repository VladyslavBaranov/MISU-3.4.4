//
//  ParamHistoryViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ParamHistoryViewCell: UICollectionViewCell {
    let itemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = true
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = .clear //UIColor.appDefault.lightGrey
        
        return cv
    }()
    
    var paramsList: [HealthParameterModel] = []
    
    var listType: SugarInsulineEnum? {
        didSet {
            guard let type = listType else { return }
            updateCollectionData(type)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCollectionView()
        guard let type = listType else { return }
        updateCollectionData(type)
    }
    
    func setUpCollectionView() {
        contentView.addSubview(itemsCollectionView)
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        
        itemsCollectionView.register(DocNeedsCell.self, forCellWithReuseIdentifier: SugarInsulineEnum.insuline.rawValue)
        
        itemsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        itemsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        itemsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        itemsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    func updateCollectionData(_ type: SugarInsulineEnum) {
        switch type {
        case .sugar:
            paramsList = (self.superview?.controller() as? SugarInsulinHistoryVC)?.sugarDataList ?? []
        case .insuline:
            paramsList = (self.superview?.controller() as? SugarInsulinHistoryVC)?.insulinDataList ?? []
        }
        
        itemsCollectionView.reloadData()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            (self.superview?.controller() as? SugarInsulinHistoryVC)?.updateData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
