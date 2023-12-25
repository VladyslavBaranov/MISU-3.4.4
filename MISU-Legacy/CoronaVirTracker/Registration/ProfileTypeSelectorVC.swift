//
//  ProfileTypeSelectorVC.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/1/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class ProfileTypeSelectorVC: UIViewController {
    let infoLabel: UILabel = .createTitle(text: NSLocalizedString("Select your profile", comment: ""),
                                          fontSize: 24,
                                          color: .black,
                                          alignment: .center)
    
    let imPtientButton: UICustomSelectorButton = UICustomSelectorButton()
    let imDoctorButton: UICustomSelectorButton = UICustomSelectorButton(image: UIImage(named: "ImDoctor"),
                                                                        text: NSLocalizedString("I'm a doctor", comment: ""))
    
    let nextButton: UIButton = .createCustom(title: NSLocalizedString("Next", comment: ""))
    
    var authModel: AuthenticationModel = AuthenticationModel()
    
    convenience init(auth: AuthenticationModel) {
        self.init()
        authModel = auth
    }
}



// MARK: - SetUp Methods
extension ProfileTypeSelectorVC {
    func setUpView() {
        view.backgroundColor = UIColor.appDefault.lightGrey
        view.addEndEditTapRecognizer()
    }
    
    func setUpNavigationView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setUpSubViews() {
        view.addSubview(infoLabel)
        view.addSubview(imPtientButton)
        view.addSubview(imDoctorButton)
        view.addSubview(nextButton)
        
        infoLabel.numberOfLines = 2
        infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.standartInset).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        
        imPtientButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: view.standartInset*2).isActive = true
        imPtientButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        imPtientButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        imPtientButton.heightAnchor.constraint(greaterThanOrEqualToConstant: view.standartInset).isActive = true
        imPtientButton.customDelegate = self
        
        imDoctorButton.topAnchor.constraint(equalTo: imPtientButton.bottomAnchor, constant: view.standartInset).isActive = true
        imDoctorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        imDoctorButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        imDoctorButton.heightAnchor.constraint(equalTo: imPtientButton.heightAnchor).isActive = true
        imDoctorButton.customDelegate = self
        
        nextButton.topAnchor.constraint(equalTo: imDoctorButton.bottomAnchor, constant: view.standartInset*2).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.standartInset*2).isActive = true
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        showNextButton(false, duration: 0)
    }
}



// MARK: - View loads Overrides
extension ProfileTypeSelectorVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpNavigationView()
        setUpSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareViewsBeforReqest(viewsToBlock: [nextButton], UIViewsToBlock: [imPtientButton, imDoctorButton])
        nextButton.startActivity(style: .medium, color: .white)
        UCardSingleManager.shared.getCurrUser(request: true) { _ in
            self.enableViewsAfterReqest()
            self.nextButton.stopActivity()
        }
    }
}



// MARK: - Buttons actions
extension ProfileTypeSelectorVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func nextAction() {
        if imPtientButton.isSelected ?? false {
            let profile = UserCardModel(age: 0, gender: .get(0), status: .well)
            prepareViewsBeforReqest(viewsToBlock: [nextButton], UIViewsToBlock: [imPtientButton, imDoctorButton])
            nextButton.startActivity(style: .medium)
            UserManager.shared.createProfile(self.authModel.token, profile: profile) { (newProfile, error) in
                self.enableViewsAfterReqest()
                self.nextButton.stopActivity()
                
                if let prof = newProfile {
                    let old = UCardSingleManager.shared.user
                    UCardSingleManager.shared.user.profile = prof
                    UCardSingleManager.shared.user.userType = .patient
                    UCardSingleManager.shared.saveCurrUser(oldUser: old)
                    ModalMessagesController.shared.show(message: "Success", type: .success)
                    DispatchQueue.main.async { self.navigationController?.popToRootViewController(animated: true) }
                }
                
                if let er = error {
                    ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                }
            }
            return
        }
        
        if imDoctorButton.isSelected ?? false {
            let doctor = DoctorModel(diploma: "", position: .init(id: 0, name: ""))
            prepareViewsBeforReqest(viewsToBlock: [nextButton], UIViewsToBlock: [imPtientButton, imDoctorButton])
            nextButton.startActivity(style: .medium)
            UserManager.shared.createDoctor(authModel.token, doctor: doctor) { (newDoctor, error) in
                self.enableViewsAfterReqest()
                self.nextButton.stopActivity()
                
                if let doc = newDoctor {
                    let old = UCardSingleManager.shared.user
                    UCardSingleManager.shared.user.doctor = doc
                    UCardSingleManager.shared.user.userType = UserTypeEnum.determine(UCardSingleManager.shared.user)
                    UCardSingleManager.shared.saveCurrUser(oldUser: old)
                    ModalMessagesController.shared.show(message: "Success", type: .success)
                    DispatchQueue.main.async { self.navigationController?.popToRootViewController(animated: true) }
                }
                
                if let er = error {
                    ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                }
            }
            return
        }
    }
}



// MARK: - Other methods
extension ProfileTypeSelectorVC {
    func showNextButton(_ show: Bool, duration: Double = 0.3) {
        nextButton.isEnabled = show
        if show {
            nextButton.animateShow(duration: duration)
        } else {
            nextButton.animateFade(duration: duration)
        }
    }
}



// MARK: - UICustomSelectorButton Delegate
extension ProfileTypeSelectorVC: UICustomSelectorButtonDelegate {
    func selectorButtonDidTap(_ selectorButton: UICustomSelectorButton) {
        if selectorButton == imPtientButton {
            imDoctorButton.isSelected = false
        } else {
            imPtientButton.isSelected = false
        }
        showNextButton(selectorButton.isSelected ?? false)
    }
}
