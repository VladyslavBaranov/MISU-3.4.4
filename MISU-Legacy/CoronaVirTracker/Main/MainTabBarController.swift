//
//  MainTabBarController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    func setSelectedTab(index: Int, animated: Bool = true) {
        guard let viewC = self.viewControllers?[index] else { return }
        if animated {
            _ = self.tabBarController(self, shouldSelect: viewC)
            self.selectedViewController = viewC
        } else {
            selectedIndex = index
        }
    }
    
    var listForDoctor: UIViewController? = MainTabBarStructEnum.watch.patientsViewController
    var watchForPatient: UIViewController? = MainTabBarStructEnum.watch.viewController
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBar.isTranslucent = false
        initTabs()
        updateTabs()
        self.selectedIndex = MainTabBarStructEnum.profile.rawValue
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //tabBarController?.viewControllers = [NewsListVC(), MapVC(), WatchVC(), ProfileVC()]
        //fatalError("init(coder:) has not been implemented")
    }
    
    func initTabs() {
        let tabVCs = MainTabBarStructEnum.allCases.map { tab -> UIViewController in
            return tab.viewController
        }
        setViewControllers(tabVCs, animated: false)
    }
    
    func updateTabs() {
        if let vcs = viewControllers, vcs.count > 0 {
            var contrUpd: [UIViewController] = []
            MainTabBarStructEnum.allCases.forEach { tab in
                guard let vc = viewControllers?[safe: tab.rawValue] else { return }
                guard tab == .watch else {
                    contrUpd.append(vc)
                    return
                }
                if UCardSingleManager.shared.user.doctor != nil, UCardSingleManager.shared.isUserToken() {
                    contrUpd.append(listForDoctor ?? vc)
                } else {
                    contrUpd.append(watchForPatient ?? vc)
                }
            }
            setViewControllers(contrUpd, animated: false)
            return
        }
        
        var contrNew: [UIViewController] = []
        MainTabBarStructEnum.allCases.forEach { tab in
            contrNew.append(tab.viewController)
        }
        setViewControllers(contrNew, animated: false)
    }
}

extension MainTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        self.selectedIndex = MainTabBarStructEnum.profile.rawValue
        ChatsSinglManager.shared.tabBarDelegate = self
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTabs()
    }
    
    func setup() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        tabBar.tintColor = UIColor.appDefault.red
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
    }
}



// MARK: - UITabBarController Delegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            print("MainTabBarController: false")
            return false
        }
        
        if selectedViewController?.children.first(where: { ($0 as? RegistrationVC) != nil }) != nil,
            viewController.children.first(where: { ($0 as? RegistrationVC) != nil }) != nil {
            return false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.1, options: [.transitionCrossDissolve], completion: nil)
        }
        
        return true
    }
}



// MARK: - TabBar NewMessages Delegate
extension MainTabBarController: TabBarNewMessagesDelegate {
    func gotNewMessage(_ count: Int) {
        let newValue: String? = count > 0 ? String(count) : nil
        DispatchQueue.main.async {
            self.tabBar.items?[MainTabBarStructEnum.profile.rawValue].badgeValue = newValue
        }
    }
}
