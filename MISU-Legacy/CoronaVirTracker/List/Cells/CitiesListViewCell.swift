//
//  CitiesListViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class CitiesListViewCell: UICollectionViewCell {
    let citiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = true
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = true
        cv.backgroundColor = .clear
        
        return cv
    }()
    
    // sendImage
    let startButton: UIButton = .createCustom(withImage: UIImage(named: "arrowIconLeft")?.scaleTo(.init(width: 20, height: 20)),
                                              backgroundColor: UIColor.white.withAlphaComponent(0.8),
                                              imageRenderingMode: .alwaysOriginal, partCornerRadius: false,
                                              shadow: true)
    
    
    var citiesList: [String]? {
        didSet {
            guard let ct = citiesList else { return }
            //ct.sort(by: {$0.lowercased() < $1.lowercased()})
            let preCitiesCount: Int = citiesListData.count
            citiesListData = ["All"] + ct
            let afterCitiesCount = citiesListData.count > 0 ? citiesListData.count : 0
            citiesCollectionView.insertCells(preCount: preCitiesCount, afterCount: afterCitiesCount)
            //var indexestoInsert: [IndexPath] = []
            //print("###1 \(preCitiesCount) \(afterCitiesCount) \(citiesListData.count) \(indexestoInsert)")
//            if afterCitiesCount - preCitiesCount > 0 {
//                (preCitiesCount...afterCitiesCount).forEach { index in
//                    indexestoInsert.append(IndexPath(item: index, section: 0))
//                }
//            }
            //print("###2 \(preCitiesCount) \(afterCitiesCount) \(citiesListData.count) \(indexestoInsert)")
            //citiesCollectionView.insertItems(at: indexestoInsert)
            //citiesCollectionView.reloadData()
        }
    }
    
    var listType: ListStructEnum?
    
    var citiesListData: [String] = []
    var selectedCityIndex: Int = 0
    
    var selectedCity: String? {
        didSet {
            guard let sc = selectedCity else { return }
            selectedCityIndex = citiesListData.firstIndex(of: sc) ?? 0
        }
    }
    
    static let doctorCityCellId = "DCityCellId42"
    static let hospitalCityCellId = "HCityCellId42"
    static let userCityCellId = "UCityCellId42"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCollectionView()
        updateCities()
    }
    
    func updateCities() {
        ListDHUSingleManager.shared.getCities { [self] citiesListModel in
            DispatchQueue.main.async {
                citiesList = citiesListModel.list
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > standart24Inset*2 {
            startButton.animateShow(duration: 0.1)
        }
        if scrollView.contentOffset.x <= 0 {
            startButton.animateFade(duration: 0.1)
        }
    }
    
    @objc func startButtonAction() {
        citiesCollectionView.scrollTo()
    }
    
    func setUpCollectionView() {
        contentView.addSubview(citiesCollectionView)
        contentView.addSubview(startButton)
        contentView.bringSubviewToFront(startButton)
        
        citiesCollectionView.delegate = self
        citiesCollectionView.dataSource = self
        
        citiesCollectionView.register(SymptomViewCell.self, forCellWithReuseIdentifier: CitiesListViewCell.doctorCityCellId)
        
        citiesCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        citiesCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        citiesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        citiesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        startButton.leadingAnchor.constraint(equalTo: citiesCollectionView.leadingAnchor).isActive = true
        startButton.topAnchor.constraint(equalTo: citiesCollectionView.topAnchor).isActive = true
        startButton.bottomAnchor.constraint(equalTo: citiesCollectionView.bottomAnchor).isActive = true
        startButton.animateFade(duration: 0)
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
