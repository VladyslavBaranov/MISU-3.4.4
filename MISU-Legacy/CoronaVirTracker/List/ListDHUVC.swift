//
//  ListDHUViewController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class ListDHUVC: UIViewController {
    let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        cv.isPagingEnabled = true
        
        return cv
    }()
    
    let segmentController: UISegmentedControl = {
        var items = [ListStructEnum.doctors.getItemDescription(),ListStructEnum.hospitals.getItemDescription()]
        if UCardSingleManager.shared.user.userType == UserTypeEnum.doctor || UCardSingleManager.shared.user.userType == UserTypeEnum.familyDoctor {
            items = [ListStructEnum.doctors.getItemDescription(),
                     ListStructEnum.hospitals.getItemDescription(),
                     ListStructEnum.users.getItemDescription()]
        }
        
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    var numberOfListSections: Int {
        get {
            if UCardSingleManager.shared.user.userType == .doctor || UCardSingleManager.shared.user.userType == .familyDoctor {
                return 3
            }
            return 2
        }
    }
}



// MARK: - SetUp Methods
extension ListDHUVC {
    func setUpCollectionView() {
        view.addSubview(mainCollectionView)
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        mainCollectionView.register(ItemsListViewCell.self, forCellWithReuseIdentifier: NewsCellIds.additionalNews.rawValue)
        
        mainCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        view.backgroundColor = UIColor.appDefault.lightGrey
    }
    
    func setUpNavigationView() {
        navigationItem.titleView = segmentController
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setUpSegmentController() {
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
    }
}



// MARK: - View loads Overrides
extension ListDHUVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationView()
        setUpCollectionView()
        setUpSegmentController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateData()
        //mainCollectionView.reloadData()
        //ListDHUTaskSingletonManager.shared.doTask(listVC: self)
//        HospitalsManager.shared.getCities(page: 1) { (citiesOp, errorOp) in
//            print("### city S \(String(describing: citiesOp))")
//            print("### city E \(String(describing: errorOp))")
//        }
    }
}



// MARK: - Scroll view overloads
extension ListDHUVC {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let segment = Int((scrollView.contentOffset.x/view.frame.width).rounded(.toNearestOrAwayFromZero))
        selectCorrectSegment(segment)
    }
}



// MARK: - Other methods
extension ListDHUVC {
    func updateData() {
        print("### update data")
        if (UCardSingleManager.shared.user.userType == UserTypeEnum.doctor || UCardSingleManager.shared.user.userType == UserTypeEnum.familyDoctor) && segmentController.numberOfSegments == 2 {
            segmentController.insertSegment(withTitle: ListStructEnum.users.getItemDescription(), at: 2, animated: true)
            if mainCollectionView.numberOfSections < 3 {
                mainCollectionView.insertSections([ListStructEnum.users.rawValue])
                mainCollectionView.reloadSections([ListStructEnum.users.rawValue])
            }
        } else if UCardSingleManager.shared.user.userType != UserTypeEnum.doctor && UCardSingleManager.shared.user.userType != UserTypeEnum.familyDoctor && segmentController.numberOfSegments == 3 {
            segmentController.removeSegment(at: 2, animated: true)
            if mainCollectionView.numberOfSections > 2 {
                mainCollectionView.deleteSections([ListStructEnum.users.rawValue])
            }
        }
        
//        ListDHUSingleManager.shared.updateData {
//            DispatchQueue.main.async {
//                self.mainCollectionView.reloadData()
//            }
//        }
    }
    
    func selectCorrectSegment(_ segment: Int = 0) {
        if segment != segmentController.selectedSegmentIndex {
            segmentController.selectedSegmentIndex = segment
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        let section = segment.selectedSegmentIndex
        mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: section), at: .init(), animated: true)
//        if section == 1 {
//            navigationItem.searchController = .init()
//        } else {
//            navigationItem.searchController = nil
//        }
    }
}
