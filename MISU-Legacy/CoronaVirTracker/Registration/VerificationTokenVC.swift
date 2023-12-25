//
//  VerificationTokenVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 29.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import FirebaseAuth

let appleDocLogIn = "+380874367292"
let applePatLogIn = "+380874367291"
let applePinToken = "424242"
let appleDocToken = "fe4b122353ebb3e56c0439447eb548e35a493bcd"
let applePatToken = "a73697d67d1c75d57f0dd12cc0c7ce8b69bae8c4"

// MARK: - Components
class VerificationTokenVC: UIViewController {
    let credentialsLabel: UILabel = .createTitle(text: NSLocalizedString("Credentials", comment: ""),
                                                 fontSize: 34,
                                                 color: .black,
                                                 alignment: .center)
    
    let infoLabel: UILabel = .createTitle(text: NSLocalizedString("", comment: ""),
                                          fontSize: 14,
                                          color: .lightGray,
                                          alignment: .center)
    
    let messageLabel: UILabel = .createTitle(text: "",
                                             fontSize: 16,
                                             color: .black,
                                             alignment: .left)
    
    let sendAginButton: UIButton = .createCustom(title: NSLocalizedString("Send again", comment: ""),
                                                 color: .clear,
                                                 textColor: UIColor.appDefault.red,
                                                 shadow: false,
                                                 customContentEdgeInsets: false)
    
    let nextButton: UIButton = .createCustom(title: NSLocalizedString("Next", comment: ""))
    
    var tokenTextFieldView: UIPinUnderLinedTextFieldView = UIPinUnderLinedTextFieldView()
    
    var authModel: AuthenticationModel = AuthenticationModel()
    
    var blockSABTimer: Timer? = nil
    
    convenience init(auth: AuthenticationModel, needSMS: Bool = true) {
        self.init()
        authModel = auth
        authModelDidSet()
        if needSMS, !authModel.wasNumberToWaitSMS() { requestCode() }
        else {
            //sendAginButton.startActivity(style: .medium, color: .lightGray)
            //startTimerToBlockSAB()
        }
    }
}



// MARK: - View loads Overrides
extension VerificationTokenVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpNavigationView()
        setUpSubViews()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}



// MARK: - RequestUIController
extension VerificationTokenVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    /*func startTimerToBlockSAB() {
        blockSABTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: { _ in
            DispatchQueue.main.async {
                self.sendAginButton.stopActivity()
            }
        })
    }*/
    
    func requestCode() {
        prepareViewsBeforReqest(viewsToBlock: [nextButton] + tokenTextFieldView.underLineTextFields)
        nextButton.startActivity(style: .medium)
        sendAginButton.startActivity(style: .medium, color: .lightGray)
        //startTimerToBlockSAB()
        AuthManager.shared.registration(authModel: authModel) { (success, error) in
            self.enableViewsAfterReqest()
            self.nextButton.stopActivity()
            if let detail = success {
                ModalMessagesController.shared.show(message: detail, type: .success)
                
                self.authModel.waitingForSMS()
            }
            
            if let er = error {
                self.blockSABTimer?.fire()
                ModalMessagesController.shared.show(message: er.errorResponse?.details ?? er.error, type: .error)
            }
        }
    }
}



// MARK: - Buttons actions
extension VerificationTokenVC {
    @objc func sendAginButtonAction() {
        requestCode()
    }
    
    @objc func nextAction() {
        if tokenTextFieldView.text.count == 6 {
            authModel.pinToken = tokenTextFieldView.text
            prepareViewsBeforReqest(viewsToBlock: [sendAginButton, nextButton] + tokenTextFieldView.underLineTextFields, activityButton: nextButton)
            
            auth()
        } else {
            tokenTextFieldView.alertAnimation()
        }
    }
    
    func auth() {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: authModel.firebaseVerificationID,
            verificationCode: authModel.pinToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("FB Auth ERROR: \(error.localizedDescription)")
                ModalMessagesController.shared.show(message: "Auth: " + error.localizedDescription, type: .error)
                self.enableViewsAfterReqest()
            }
            
            // User is signed in
            // ...
            if let token = authResult?.user.uid {
                //print("FB token: \(token)")
                self.authModel.firebaseUid = token
                self.getFIDToken()
            } else {
                self.enableViewsAfterReqest()
            }
        }
    }
    
    func getFIDToken() {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print("FB getIDTokenForcingRefresh ERROR: \(error.localizedDescription)")
                ModalMessagesController.shared.show(message: "FireId: " + error.localizedDescription, type: .error)
                self.enableViewsAfterReqest()
                return
            }

            // Send token to your backend via HTTPS
            // ...
            if let it = idToken {
                self.authModel.firebaseUid = it
                self.logIn()
            } else {
                self.enableViewsAfterReqest()
            }
        }
    }
    
    func logIn() {
        AuthManager.shared.logIn(self.authModel) { (token, error) in
            if let tok = token {
                self.authModel.token = tok
                guard KeychainUtils.saveCurrentUserToken(tok) else {
                    ModalMessagesController.shared.show(message: NSLocalizedString("Someting went wrong ... /nTry agin later", comment: ""), type: .error)
                    return
                }
                ModalMessagesController.shared.show(message: "Success", type: .success)
                self.authModel.gotSMS()
                ChatsSinglManager.shared.clearCache()
                if self.authModel.isRegistration {
                    DispatchQueue.main.async { self.goToProfileTypeSelector() }
                } else {
                    DispatchQueue.main.async { self.goToProfile() }
                }
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.errorResponse?.token?.first ?? er.errorResponse?.nonFields?.first ?? er.error, type: .error)
            }
            self.enableViewsAfterReqest()
        }
    }
}



// MARK: - Other methods
extension VerificationTokenVC {
    func goToProfile() {
        UserManager.shared.getCurrent(authModel.token) { (requestedUser, error) in
            if var user = requestedUser {
                user.isCurrent = true
                user.userType = UserTypeEnum.determine(user)
                let old = UCardSingleManager.shared.user
                UCardSingleManager.shared.user = user
                UCardSingleManager.shared.saveCurrUser(oldUser: old)
            }
            
            if let er = error {
                ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
            }
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToProfileTypeSelector() {
        DispatchQueue.main.async {
            let vc = ProfileTypeSelectorVC(auth: self.authModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func authModelDidSet() {
        credentialsLabel.text = authModel.credentials
        infoLabel.text = authModel.getInfoLabelText()
    }
}



// MARK: - Pin textFieldView delegate
extension VerificationTokenVC: UIPinUnderLinedTextFieldViewDelegate {
    func pinTextFieldDidEndFilling(text: String) {
        tokenTextFieldView.doneAnimation(completion: {
            self.nextAction()
        })
    }
}



// MARK: - SetUp Methods
extension VerificationTokenVC {
    func setUpView() {
        view.backgroundColor = UIColor.white
        view.addEndEditTapRecognizer()
    }
    
    func setUpNavigationView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setUpSubViews() {
        view.addSubview(credentialsLabel)
        view.addSubview(infoLabel)
        view.addSubview(messageLabel)
        view.addSubview(tokenTextFieldView)
        view.addSubview(sendAginButton)
        view.addSubview(nextButton)
        
        credentialsLabel.adjustsFontSizeToFitWidth = true
        credentialsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                              constant: credentialsLabel.frame.height*2).isActive = true
        credentialsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        credentialsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        
        infoLabel.numberOfLines = 2
        infoLabel.topAnchor.constraint(equalTo: credentialsLabel.bottomAnchor, constant: view.standartInset*2).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: view.standartInset*2).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        
        tokenTextFieldView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: view.standartInset).isActive = true
        tokenTextFieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tokenTextFieldView.pinDelegate = self
        
        sendAginButton.topAnchor.constraint(equalTo: tokenTextFieldView.bottomAnchor, constant: view.standartInset).isActive = true
        sendAginButton.trailingAnchor.constraint(equalTo: tokenTextFieldView.trailingAnchor).isActive = true
        sendAginButton.addTarget(self, action: #selector(sendAginButtonAction), for: .touchUpInside)
        
        nextButton.topAnchor.constraint(equalTo: sendAginButton.bottomAnchor, constant: view.standartInset).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: tokenTextFieldView.leadingAnchor).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: tokenTextFieldView.trailingAnchor).isActive = true
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    }
}
