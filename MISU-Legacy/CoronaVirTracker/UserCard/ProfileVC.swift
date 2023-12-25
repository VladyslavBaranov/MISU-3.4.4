//
//  ProfileVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class ProfileVC: UIViewController {
    let profileCollectionView: UICollectionView = {
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
    
    var userModel: UserModel? {
        didSet {
            if let name = userModel?.profile?.name {
                navigationItem.title = name
                return
            } else {
                navigationItem.title = NSLocalizedString("Profile", comment: "")
            }
            
            if let name = userModel?.doctor?.fullName {
                navigationItem.title = name
            }
        }
    }
    
    var isCurrentUser = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ user: UserModel?, isCurrent curr: Bool) {
        super.init(nibName: nil, bundle: nil)
        setUser(user, isCurrent: curr)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}



// MARK: - SetUp Methods
extension ProfileVC {
    func setUpView() {
        view.backgroundColor = UIColor.white
    }
    
    func setUpCollectionView() {
        view.addSubview(profileCollectionView)
        
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        
        collectionRegisterCells()
        
        profileCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        profileCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        profileCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        profileCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setUpNavigationViewBeforRegistr() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setUpNavigationView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        
        if isCurrentUser {
            addChatsNavButton()
            addMenuNavButton()
        }
    }
}



// MARK: - View loads Overrides
extension ProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpNavigationViewBeforRegistr()
        setUpCollectionView()
        
        setUpNavigationView()
        prepareUser(request: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareUser(request: true)
        //if isCurrentUser { prepareUser(request: false) }
        //else { prepareUser(request: true) }
    }
}



// MARK: - Scrolling methods
extension ProfileVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            prepareUser(request: true)
        }
    }
}



// MARK: - User methods
extension ProfileVC {
    func reloadUserProfile(request: Bool) {
        userModel = UCardSingleManager.shared.getUser()
        //GroupsSingleManager.shared.getAll()
        profileCollectionView.reloadData()
        if !request { return }
        UCardSingleManager.shared.getCurrUser(request: request) { user in
            DispatchQueue.main.async {
                self.userModel = user
                self.setUpNavigationView()
                self.profileCollectionView.reloadData()
            }
        }
    }
    
    func prepareUser(request: Bool) {
        if isCurrentUser {
            if !isUserRegistered() {
                let vc = RegistrationVC()
                navigationController?.pushViewController(vc, animated: false)
                return
            }
            UCardSingleManager.shared.getCurrUser(request: request) { user in
                DispatchQueue.main.async {
                    self.userModel = user
                    self.setUpNavigationView()
                    self.profileCollectionView.reloadData()
                    GroupsSingleManager.shared.update()
                    self.checkUserProfile()
                    //print(user)
                }
            }
            PushNotificationManager.shared.getNotificationSettings()
        } else {
            if userModel?.doctor != nil {
                ListDHManager.shared.getAllDoctors(onlyOneDoctor: userModel, one: true) { (doctorList, error) in
                    if let newDoc = doctorList?.first {
                        DispatchQueue.main.async {
                            self.userModel = newDoc
                            self.profileCollectionView.reloadData()
                        }
                    }
                    
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.message, type: .error)
                    }
                }
            } else if userModel?.profile != nil {
                guard let uId = userModel?.profile?.id else { return }
                _ = ListDHManager.shared.getProfile(id: uId) { (patientList, error) in
                    //print("### req \(String(describing: patientList))")
                    if let newPatient = patientList?.first {
                        DispatchQueue.main.async {
                            //newPatient.profile?.familyDoctor = self.userModel?.profile?.familyDoctor
                            self.userModel?.profile = newPatient.profile
                            self.profileCollectionView.reloadData()
                        }
                    }
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                    }
                }
            }
        }
    }
    
    func checkUserProfile() {
        if navigationController?.children.first(where: {($0 as? ProfileTypeSelectorVC) != nil}) != nil ||
           navigationController?.children.first(where: {($0 as? NameAgeRegistrationVC) != nil}) != nil { return }
        if userModel?.profile == nil && userModel?.doctor == nil {
            guard let token = KeychainUtils.getCurrentUserToken() else { return }
            let vc = ProfileTypeSelectorVC(auth: AuthenticationModel(token: token))
            navigationController?.pushViewController(vc, animated: true)
        }
        if navigationController?.children.first(where: {($0 as? ProfileTypeSelectorVC) != nil}) != nil ||
           navigationController?.children.first(where: {($0 as? NameAgeRegistrationVC) != nil}) != nil { return }
        if (UCardSingleManager.shared.user.profile?.name == nil && UCardSingleManager.shared.user.doctor?.fullName == nil) ||
           ((UCardSingleManager.shared.user.profile?.name?.isEmpty ?? true) && (UCardSingleManager.shared.user.doctor?.fullName?.isEmpty ?? true)) {
            let vc = NameAgeRegistrationVC(user: UCardSingleManager.shared.user)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        (tabBarController as? MainTabBarController)?.updateTabs()
    }
    
    func setUser(_ user: UserModel?, isCurrent curr: Bool) {
        //print("### user \(String(describing: user))")
        userModel = user
        isCurrentUser = curr
        profileCollectionView.reloadData()
    }
    
    func isUserRegistered() -> Bool {
        if UCardSingleManager.shared.isUserToken() {
            return true
        }
        return false
    }
}



// MARK: - Other methods
extension ProfileVC {
    @objc func drugsButtonAction() {
        /*guard var drugChat = ChatsSinglManager.shared.getDrugsChat() else { return }
        drugChat.messages = Array(drugChat.messages.prefix(20))
        let vc = ChatVC(chat: drugChat)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)*/
    }
    
    func collectionRegisterCells() {
        PatientPStructEnum.collectionRegisterCells(profileCollectionView)
        OtherSectionEnum.collectionRegisterCells(profileCollectionView)
        DoctorPStructEnum.collectionRegisterCells(profileCollectionView)
        //FamilyDoctorProfStructEnum.collectionRegisterCells(profileCollectionView)
    }
}
