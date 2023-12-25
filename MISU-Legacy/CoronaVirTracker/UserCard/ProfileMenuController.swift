//
//  ProfileMenuController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension ProfileVC {
    func addMenuNavButton() {
        let menuButton = UIBarButtonItem.menuButton(target: self, action: #selector(showMenuController), image: UIImage(named: "menuNavButtonBlueL"), size: CGSize(width: navigationBarHeight*0.55, height: navigationBarHeight*0.55))
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc fileprivate func showMenuController() {
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { _ in
            self.settingsButtonTapped()
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Help", comment: ""), style: .default, handler: { _ in
            self.moreInformationAction()
        }))
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = navigationItem.rightBarButtonItem?.customView
        present(menuController, animated: true)
    }
    
    fileprivate func settingsButtonTapped() {
        let vc = SettingsVC(user: userModel)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func moreInformationAction() {
        let link = "https://sites.google.com/view/misu-ua/questions"
        guard let url = URL(string: link), link.lowercased().components(separatedBy: "http").count > 1 else {
            print("Wrong url ...")
            return
        }
        UIApplication.shared.open(url)
    }
}
