//
//  RegistrationVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 27.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import FirebaseAuth
import PhoneNumberKit

// MARK: - Components
class RegistrationVC: UIViewController {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Welcome", comment: ""), fontSize: 34, color: .black, alignment: .center)
    let messageLabel: UILabel = .createTitle(text: "", fontSize: 16, color: .black, alignment: .left)
    
    let logInButton: UIButton = .createCustom(title: NSLocalizedString("Log in", comment: ""))
    let registrButton: UIButton = .createCustom(title: NSLocalizedString("Create new", comment: ""), color: UIColor.appDefault.lightGrey, textColor: .gray)
    
    let privacyPButton: UIButton = .createCustomButton(
        title: NSLocalizedString("By using MISU App you automatically confirm that you have read and agree with terms of Privacy Policy", comment: ""),
        color: .clear, fontSize: 12, textColor: .gray, shadow: false, customContentEdgeInsets: false)
    
    let phoneNumberTF = CustomPhoneNumberTF()
    
    var authModel: AuthenticationModel = AuthenticationModel()
}



// MARK: - SetUp Methods
extension RegistrationVC {
    func setUpView() {
        view.backgroundColor = UIColor.white
        view.addEndEditTapRecognizer()
    }
    
    func setUpNavigationView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.hidesBackButton = true
    }
    
    func setUpSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        //view.addSubview(emailTextField)
        view.addSubview(phoneNumberTF)
        view.addSubview(logInButton)
        view.addSubview(registrButton)
        view.addSubview(privacyPButton)
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                        constant: titleLabel.frame.height*2 + view.standartInset).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        
        messageLabel.numberOfLines = 2
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: view.standartInset*2).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        
        phoneNumberTF.delegate = self
        phoneNumberTF.withFlag = true
        phoneNumberTF.withPrefix = true
        phoneNumberTF.withDefaultPickerUI = true
        phoneNumberTF.withExamplePlaceholder = true
        PhoneNumberKit.CountryCodePicker.forceModalPresentation = true
        phoneNumberTF.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTF.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: view.standart24Inset).isActive = true
        phoneNumberTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standart24Inset).isActive = true
        phoneNumberTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standart24Inset).isActive = true
        
        logInButton.topAnchor.constraint(equalTo: phoneNumberTF.bottomAnchor, constant: view.standart24Inset*2).isActive = true
        logInButton.leadingAnchor.constraint(equalTo: phoneNumberTF.leadingAnchor).isActive = true
        logInButton.trailingAnchor.constraint(equalTo: phoneNumberTF.trailingAnchor).isActive = true
        
        registrButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: view.standartInset).isActive = true
        registrButton.leadingAnchor.constraint(equalTo: phoneNumberTF.leadingAnchor).isActive = true
        registrButton.trailingAnchor.constraint(equalTo: phoneNumberTF.trailingAnchor).isActive = true
        
        logInButton.addTarget(self, action: #selector(logInAction), for: .touchUpInside)
        registrButton.addTarget(self, action: #selector(registrAction), for: .touchUpInside)
        
        privacyPButton.titleLabel?.numberOfLines = 5
        let allText = NSLocalizedString("By using MISU App you automatically confirm that you have read and agree with terms of Privacy Policy", comment: "")
        let selectedText = NSLocalizedString("Privacy Policy", comment: "")
        let attrStr = NSMutableAttributedString(string: allText, attributes: [:])
        attrStr.setAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue,
                               .underlineColor: UIColor.gray,
                               .font:UIFont.systemFont(ofSize: 12, weight: .bold)],
                              range: (allText as NSString).range(of: selectedText))
        privacyPButton.setAttributedTitle(attrStr, for: .normal)
        privacyPButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.standartInset).isActive = true
        privacyPButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.standartInset).isActive = true
        privacyPButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -view.standartInset).isActive = true
        privacyPButton.contentMode = .scaleAspectFit
        
        if let tt = privacyPButton.titleLabel {
            privacyPButton.heightAnchor.constraint(equalTo: tt.heightAnchor).isActive = true
        }
        
        privacyPButton.addTarget(self, action: #selector(ppButtonAction), for: .touchUpInside)
        
    }
}



// MARK: - View loads Overrides
extension RegistrationVC {
    override func loadView() {
        super.loadView()
        setUpView()
        setUpNavigationView()
        setUpSubViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkIfWasTryToAuth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.popViewController(animated: false)
    }
}



// MARK: - Buttons actions
extension RegistrationVC: RequestUIController {
    @objc func ppButtonAction() {
        let vv = PrivacyPolicyVC()
        vv.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vv, animated: true)
    }
    
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func logInAction() {
        guard let logInCred = getEmailOrPhone() else {
            return
        }
        authModel.logIn(cred: logInCred)
        
        prepareViewsBeforReqest(viewsToBlock: [logInButton, registrButton, phoneNumberTF], activityButton: logInButton)
        
        AuthManager.shared.checkUser(CheckUserModel(credential: authModel.credentials)) { (isRegistered, error) in
            //self.enableViewsAfterReqest()
            if let reg = isRegistered {
                if reg.isRegistered {
                    self.goToVerificationTokenVC()
                } else {
                    self.enableViewsAfterReqest()
                    ModalMessagesController.shared.show(message: NSLocalizedString("Such user does not exist :(", comment: ""), type: .error)
                }
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.message, type: .error)
                self.enableViewsAfterReqest()
            }
        }
    }
    
    @objc func registrAction() {
        guard let registrCred = getEmailOrPhone() else {
            return
        }
        authModel.registration(cred: registrCred)
        
        prepareViewsBeforReqest(viewsToBlock: [logInButton, registrButton, phoneNumberTF], activityButton: registrButton, activityButtonColor: .lightGray)
        
        AuthManager.shared.checkUser(CheckUserModel(credential: authModel.credentials)) { (isRegistered, error) in
            //self.enableViewsAfterReqest()
            if let reg = isRegistered {
                if reg.isDoctor || reg.isProfile {
                    ModalMessagesController.shared.show(message: NSLocalizedString("Such credentials already taken :(", comment: ""), type: .error)
                    self.enableViewsAfterReqest()
                } else { self.goToVerificationTokenVC() }
            }
            
            if let er = error {
                self.enableViewsAfterReqest()
                ModalMessagesController.shared.show(message: er.message, type: .error)
            }
        }
    }
}



// MARK: - Other methods
extension RegistrationVC {
    func checkIfWasTryToAuth() {
        if authModel.wasNumberToWaitSMS() {
            phoneNumberTF.text = authModel.credentials
            goToVerificationTokenVC(needSMS: false)
        }
    }
    
    func goToVerificationTokenVC(needSMS: Bool = true) {
        if needSMS {
            phoneSMSVerification()
            return
        }
        self.enableViewsAfterReqest()
        DispatchQueue.main.async {
            let vc = VerificationTokenVC(auth: self.authModel, needSMS: needSMS)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func phoneSMSVerification() {
        //prepareViewsBeforReqest(viewsToBlock: [logInButton, registrButton, phoneNumberTF], activityButton: registrButton)
        PhoneAuthProvider.provider().verifyPhoneNumber(authModel.credentials, uiDelegate: nil) { verificationID, error in
            self.enableViewsAfterReqest()
            if let fvID = verificationID {
                self.authModel.firebaseVerificationID = fvID
                self.goToVerificationTokenVC(needSMS: false)
                //print("phoneSMSVerification verif id: \(fvID)")
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.localizedDescription, type: .error)
                print("phoneSMSVerification ERROR: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func getEmailOrPhone() -> String? {
        if let num = phoneNumberTF.text?.replacingOccurrences(of: " ", with: ""), (num == appleDocLogIn ||
            num == applePatLogIn) {
            return num
        }
        
        guard let phoneNumber = phoneNumberTF.phoneNumber, phoneNumberTF.isValidNumber else {
            phoneNumberTF.alertAnimation()
            return nil
        }
        
        let text = phoneNumberTF.phoneNumberKit.format(phoneNumber, toType: .e164)
        
        return text
    }
}
