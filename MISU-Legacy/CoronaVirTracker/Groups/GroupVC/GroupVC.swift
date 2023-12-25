//
//  GroupVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 15.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class GroupVC: UIViewController {
    let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = true
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        
        return cv
    }()
    
    //let groupSinglManager = GroupsSingleManager.shared
    var groupModel: GroupModel
    var gInvitesModels: [GroupInviteModel] = []
    
    init(group: GroupModel) {
        groupModel = group
        gInvitesModels = GroupsSingleManager.shared.getInvites(groupId: group.id)
        super.init(nibName: nil, bundle: nil)
        //modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        groupModel = .init(id: -1)
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension GroupVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        addMenuNavButtonSetUp()
        GroupsSingleManager.shared.delegate = self
    }
}



// MARK: - Actions
extension GroupVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func sendInviteAction() {
        let vc = InviteUserToGroupVC(groupId: groupModel.id) { _ in
            GroupsSingleManager.shared.update()
        }
        navigationController?.present(vc, animated: true)
    }
    
    @objc func deleteGroupAction() {
        let menuController = UIAlertController(title: NSLocalizedString("Delete group", comment: "")+"?", message: nil, preferredStyle: .actionSheet)
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { _ in
            GroupsSingleManager.shared.deleteGroup(id: self.groupModel.id)
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = navigationController?.navigationBar
        present(menuController, animated: true, completion: nil)
    }
    
    @objc func leaveGroupAction() {
        let menuController = UIAlertController(title: NSLocalizedString("Leave group", comment: "")+"?", message: nil, preferredStyle: .actionSheet)
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { _ in
            GroupsSingleManager.shared.leaveGroup()
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = navigationController?.navigationBar
        present(menuController, animated: true, completion: nil)
    }
}



// MARK: - Actions
extension GroupVC: GroupsDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            GroupsSingleManager.shared.update()
        }
    }
    
    func groupsDidUpdate(manager: GroupsSingleManager) {
        if let newGr = manager.groups.first(where: {$0.id == groupModel.id}) {
            groupModel = newGr
        }
        gInvitesModels = manager.getInvites(groupId: groupModel.id)
        mainCollectionView.reloadData()
        addMenuNavButtonSetUp()
    }
    
    func groupDidDeleted() {
        navigationController?.popViewController(animated: true)
    }
}



// MARK: - SetUp Views
extension GroupVC {
    func setUp() {
        navigationItem.title = NSLocalizedString("Family access", comment: "")
        view.backgroundColor = UIColor.appDefault.lightGrey
        
        view.addSubview(mainCollectionView)
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        mainCollectionView.register(GroupAdminViewCell.self, forCellWithReuseIdentifier: GroupStruct.info.description)
        mainCollectionView.register(UserViewCell.self, forCellWithReuseIdentifier: GroupStruct.participants.description)
        mainCollectionView.register(UserViewCell.self, forCellWithReuseIdentifier: GroupStruct.pending.description)
        mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Test")
        mainCollectionView.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GroupStruct.pending.description)
    }
    
    func addMenuNavButtonSetUp() {
        var navMenu: UIMenu = .init()
        if groupModel.isICreator {
            navMenu = UIMenu(title: "", children: [
                UIAction(title: NSLocalizedString("Send invite", comment: ""), image: UIImage(named: "inviteUser72px")?.withRenderingMode(.alwaysTemplate).withTintColor(.black)) { action in
                    print("Send invite")
                    self.sendInviteAction()
                },
                UIAction(title: NSLocalizedString("Delete Group", comment: ""), image: UIImage(named: "deleteIcon72px"), attributes: .destructive) { action in
                    print("Delete Group")
                    self.deleteGroupAction()
                }
            ])
        } else {
            navMenu = UIMenu(title: "", children: [
                UIAction(title: NSLocalizedString("Leave group", comment: ""), image: UIImage(named: "outIcon72px"), attributes: .destructive) { action in
                    print("Leave group")
                    self.leaveGroupAction()
                }
            ])
        }
        let menuButton = UIBarButtonItem.customButton(image: UIImage(named: "menuNavButtonBlueL"), menu: navMenu, parentVC: self)
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
}
