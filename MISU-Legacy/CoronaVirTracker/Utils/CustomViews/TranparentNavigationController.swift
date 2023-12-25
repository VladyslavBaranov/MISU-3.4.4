//
//  MinimalNavigationController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 16.09.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class CustomNavigatioinController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUp()
    }
    
    func setUp() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        navigationBar.isTranslucent = false
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        navigationBar.backgroundColor = .white
//
//        let navigationBarAppearance = UINavigationBarAppearance()
//        navigationBarAppearance.configureWithTransparentBackground()
//
//        navigationController?.navigationBar.tintColor = .white
//
//        navigationItem.scrollEdgeAppearance = navigationBarAppearance
//        navigationItem.standardAppearance = navigationBarAppearance
//        navigationItem.compactAppearance = navigationBarAppearance
    }
}

class TranparentNavigationController: CustomNavigatioinController {
    var bkImage: UIImage?
    var shdImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        //bkImage = navigationController?.navigationBar.backgroundImage(for: .default)
        //shdImage = navigationController?.navigationBar.shadowImage
    }
}



// MARK: - UINavigationController Delegate
extension TranparentNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setUpFor(viewController)
    }
    
    func setUpFor(_ viewController: UIViewController) {
        if (viewController as? NewVC) == nil && (viewController as? NameAgeRegistrationVC) == nil {
            //viewController.navigationController?.navigationBar.setBackgroundImage(bkImage, for: UIBarMetrics.default)
            //viewController.navigationController?.navigationBar.shadowImage = shdImage
            //setUp()
            return
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        viewController.navigationController?.navigationBar.isTranslucent = false
        viewController.navigationController?.navigationBar.standardAppearance = appearance
        //viewController.navigationController?.navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        
        //viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //viewController.navigationController?.navigationBar.shadowImage = UIImage()
        //viewController.navigationController?.navigationBar.backgroundColor = .clear
    }
}
