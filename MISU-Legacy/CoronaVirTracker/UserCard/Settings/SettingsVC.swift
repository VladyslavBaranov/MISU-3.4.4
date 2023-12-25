//
//  SettingsVC.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/13/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

struct SettingsCellIds {
    static let editableCell = "editableCell"
    static let customCell = "customCell"
}

// MARK: - Components
class SettingsVC: UIViewController {
    let settingsTableView: UITableView = .createTableView()
    let imagePickerController = UIImagePickerController()
    
    var userModel: UserModel? {
        didSet {
            let img = editedUserModel?.profile?.image ?? editedUserModel?.doctor?.image
            let name = editedUserModel?.profile?.name ?? editedUserModel?.doctor?.fullName
            
            editedUserModel = userModel
            
            if let image = img {
                editedUserModel?.profile?.image = image
                editedUserModel?.doctor?.image = image
            }
            if let nm = name {
                editedUserModel?.profile?.name = nm
                editedUserModel?.doctor?.fullName = nm
            }
        }
    }
    
    var editedUserModel: UserModel?
    var isEditPhoto: Bool = false
    
    init(user: UserModel?, editPhoto: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        userModel = user
        editedUserModel = user
        
        isEditPhoto = editPhoto
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - SetUp Methods
extension SettingsVC {
    func setUpView() {
        view.backgroundColor = UIColor.white
        view.addEndEditTapRecognizer()
    }
    
    func setUpNavigationView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneNavButtonAction))
    }
    
    func setUpTableView() {
        view.addSubview(settingsTableView)
        settingsTableView.backgroundColor = UIColor.appDefault.lightGrey
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        settingsTableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: SettingsCellIds.editableCell)
        settingsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: SettingsCellIds.customCell)
    }
    
    func setUpImagePicker() {
        imagePickerController.delegate = self
    }
}



// MARK: - View loads Overrides
extension SettingsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpNavigationView()
        setUpTableView()
        setUpImagePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ListDHManager.shared.getAllDoctors(onlyOneDoctor: userModel?.profile?.getFamilyDoctorUserModel(), one: true) { (doctorList, error) in
            if let newDoc = doctorList?.first {
                DispatchQueue.main.async {
                    self.userModel?.profile?.familyDoctor = newDoc.doctor
                    self.editedUserModel?.profile?.familyDoctor = newDoc.doctor
                }
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.message, type: .error)
            }
            
            DispatchQueue.main.async { self.settingsTableView.reloadData() }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isEditPhoto {
            isEditPhoto = false
            pickerImageAction(sender: settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.imageView)
        }
    }
}



// MARK: - Actions
extension SettingsVC {
    @objc func pickerImageAction(sender: UIView?) {
        imagePickerController.allowsEditing = true
        
        let imageSourceTypeController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imageSourceTypeController.popoverPresentationController?.sourceView = sender
        let galeryAction = UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        })
        galeryAction.customImage = UIImage(named: "QuickActions_Search")
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        })
        cameraAction.customImage = UIImage(named: "QuickActions_CapturePhoto")
        
        let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive, handler: { _ in
            self.deleteUserImage()
        })
        deleteAction.customImage = UIImage(named: "Navigation_Trash")
        
        imageSourceTypeController.addAction(galeryAction)
        imageSourceTypeController.addAction(cameraAction)
        imageSourceTypeController.addAction(deleteAction)
        
        imageSourceTypeController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(imageSourceTypeController, animated: true)
    }
    
    @objc func pickerImageActionRecog(sender: UITapGestureRecognizer?) {
        pickerImageAction(sender: sender?.view)
    }
    
    @objc func doneNavButtonAction() {
        view.endEditing(true)
        
        guard let type = userModel?.userType else { return }
        switch type {
        case .patient:
            if editedUserModel?.profile?.name != userModel?.profile?.name || editedUserModel?.profile?.image != userModel?.profile?.image {
                userModel = editedUserModel
                userModel?.saveToUserDef()
                
                guard let user = editedUserModel else { return }
                let old = UCardSingleManager.shared.user
                UCardSingleManager.shared.user = user
                UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                    if success { self.updateUser() }
                }
            }
        case .doctor, .familyDoctor:
            if editedUserModel?.doctor?.fullName != userModel?.doctor?.fullName || editedUserModel?.doctor?.image != userModel?.doctor?.image || editedUserModel?.doctor?.diplomaId != userModel?.doctor?.diplomaId {
                userModel = editedUserModel
                userModel?.saveToUserDef()
                
                guard let user = editedUserModel else { return }
                let old = UCardSingleManager.shared.user
                UCardSingleManager.shared.user = user
                UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                    if success { self.updateUser() }
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}



// MARK: - Scrolling methods
extension SettingsVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            viewWillAppear(true)
        }
    }
}



// MARK: - Other methods
extension SettingsVC {
    func updateUser() {
        userModel = UCardSingleManager.shared.user
        //DispatchQueue.main.async { self.viewDidAppear(true) }
    }
    
    func deleteUserImage() {
        guard let type = userModel?.userType else { return }
        switch type {
        case .patient:
            editedUserModel?.profile?.image = nil
        case .doctor, .familyDoctor:
            editedUserModel?.doctor?.image = nil
        }
        settingsTableView.reloadData()
    }
    
    func logOutNavButtonTapped(sender: UIView?) {
        let menuController = UIAlertController(title: NSLocalizedString("Log out", comment: "")+"?", message: nil, preferredStyle: .actionSheet)
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { _ in
            UCardSingleManager.shared.logOutUser()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Keep me here", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = sender
        present(menuController, animated: true, completion: nil)
    }
    
    func clearCacheTapped(sender: UIView?) {
        let menuController = UIAlertController(title: NSLocalizedString("Clear cache", comment: "")+" (\(ImageCM.shared.covertToString(size: (ImageCM.shared.getSize() ?? 0) + (ChatCM.shared.getSize() ?? 0))))?", message: nil, preferredStyle: .actionSheet)
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Clear", comment: ""), style: .destructive, handler: { _ in
            ImageCM.shared.clear()
            ChatCM.shared.clearCache()
            self.settingsTableView.reloadData()
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Keep", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = sender
        present(menuController, animated: true, completion: nil)
        
        
    }
}
