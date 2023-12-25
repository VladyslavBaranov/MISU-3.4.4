//
//  HospitalVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 14.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class HospitalVC: UIViewController {
    let hospCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        
        return cv
    }()
    
    var hospital: HospitalModel? {
        didSet {
            self.hospCollectionView.reloadData()
        }
    }
}



// MARK: - SetUp Methods
extension HospitalVC {
    func setUpView() {
        view.backgroundColor = UIColor.white
    }
    
    func setUpCollectionView() {
        view.addSubview(hospCollectionView)
        
        hospCollectionView.delegate = self
        hospCollectionView.dataSource = self
        
        HospitalStructEnum.collectionRegisterCells(hospCollectionView)
        
        hospCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        hospCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        hospCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        hospCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setUpNavigationView() {
        navigationItem.title = NSLocalizedString("Hospital", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}



// MARK: - View loads Overrides
extension HospitalVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpCollectionView()
        setUpNavigationView()
        hospCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let hosp = hospital else { return }
        //print("### pre hosp VC \(hosp)")
        HospitalsManager.shared.getHospital(by: hosp.id) { (hospitalsList, error) in
            //print("### after hosp VC \(hospitalsList)")
            if let newHosp = hospitalsList?.first {
                DispatchQueue.main.async {
                    print(newHosp)
                    self.hospital = newHosp
                }
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.message, type: .error)
            }
        }
    }
}



// MARK: - Scrolling methods
extension HospitalVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            viewDidAppear(true)
        }
    }
}



// MARK: - Other methods
extension HospitalVC {
    
}
