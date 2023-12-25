//
//  MainTabBarStructEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum MainTabBarStructEnum: Int, EnumKit, CaseIterable {
    case news = 0
    case map = 1
    case watch = 2
    case profile = 3
    
    var viewController: UIViewController {
        switch self {
        case .news:
            let _vc = vc
            _vc.tabBarItem = tabBarItem
            return TranparentNavigationController(rootViewController: _vc)
        default:
            let _vc = vc
            _vc.tabBarItem = tabBarItem
            return CustomNavigatioinController(rootViewController: _vc)
        }
    }
    
    var tabBarItem: UITabBarItem {
        return .init(title: localized, image: image, tag: rawValue)
    }
    
    var vc: UIViewController {
        switch self {
        case .news:
            return NewsListVC()
            //return UIStoryboard(name: "NewsList", bundle: nil).instantiateInitialViewController()
        case .map:
            return MapVC()
            //return UIStoryboard(name: "Map", bundle: nil).instantiateInitialViewController()
        case .watch:
            return WatchVC()
            //return UIStoryboard(name: "Watch", bundle: nil).instantiateInitialViewController()
        case .profile:
            return ProfileVC()
            //return UIStoryboard(name: "UserCard", bundle: nil).instantiateInitialViewController()
        }
    }
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    
    //var iconSize: CGSize { return .init(width: Constants.iconHeight, height: Constants.iconHeight) }
    
    var imageName: String {
        switch self {
        case .news:
            return "newsIcon"
        case .map:
            return "List"
        case .watch:
            return "Watch"
        case .profile:
            return "personTabIcon"
        }
    }
    
    var localized: String {
        switch self {
        case .news:
            return NSLocalizedString("News", comment: "")
        case .map:
            return NSLocalizedString("Map", comment: "")
        case .watch:
            return NSLocalizedString("Watch", comment: "")
        case .profile:
            return NSLocalizedString("Medical ID", comment: "")
        }
    }
    
    var patientsViewController: UIViewController {
        let _vc = patientsList
        _vc.tabBarItem = patientsTabBarItem
        return UINavigationController(rootViewController: _vc)
    }
    
    var patientsTabBarItem: UITabBarItem {
        return .init(title: patientsLocalized, image: patientsImage, tag: MainTabBarStructEnum.watch.rawValue)
    }
    
    var patientsList: UIViewController {
        return PatientsVC()
        //get { return UIStoryboard(name: "PatientsList", bundle: nil).instantiateInitialViewController() }
    }
    
    var patientsImage: UIImage? {
        return UIImage(named: patientsImageName)
    }
    
    var patientsImageName: String {
        return "patientsListIcon"
        //get { return UIStoryboard(name: "PatientsList", bundle: nil).instantiateInitialViewController() }
    }
    
    var patientsRawValue: String {
        return "patientsListRaw"
    }
    
    var patientsLocalized: String? {
        return NSLocalizedString("Patients", comment: "")
        //get { return UIStoryboard(name: "PatientsList", bundle: nil).instantiateInitialViewController() }
    }
}
