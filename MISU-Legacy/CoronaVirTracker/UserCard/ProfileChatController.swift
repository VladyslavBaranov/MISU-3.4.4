//
//  ProfileChatController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 23.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension ProfileVC {
    func addChatsNavButton() {
        if self.navigationItem.leftBarButtonItem?.customView != nil { return }
        //chatIconNew
        //let chatButton = UIBarButtonItem.customButton(image: UIImage(named: "chatIconNew"), target: self, action: #selector(showChatsListVC), parentVC: self)
        let chatButton = UIBarButtonItem.menuButton(target: self, action: #selector(showChatsListVC), image: UIImage(named: "chatIconNew"), size: CGSize(width: navigationBarHeight*0.55, height: navigationBarHeight*0.55))
        navigationItem.leftBarButtonItem = chatButton
        navigationItem.leftBarButtonItem?.tintColor = .black
        ChatsSinglManager.shared.chatsIconDelegate = self
    }
    
    @objc func showChatsListVC() {
        let vc = ChatsListVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        return
    }
}



extension ProfileVC: ChatsIconNewMessagesDelegate {
    func gotNewMessage(_ count: Int) {
        let newValue: String? = count > 0 ? String(count) : nil
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem?.customView?.budgetValueCustom = newValue
            //self.navigationItem.leftBarButtonItem?.budgetValueCustom = newValue
        }
    }
}

