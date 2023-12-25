//
//  InviteUserToGroupVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 14.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import PhoneNumberKit

class InviteUserToGroupVC: UIViewController {
    let skipButton: UIButton = .createCustom(title: NSLocalizedString("Skip", comment: ""),
                                             color: .clear, fontSize: 16, textColor: UIColor.appDefault.red,
                                             shadow: false, customContentEdgeInsets: true, setCustomCornerRadius: false)
    
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Family access", comment: ""), fontSize: 24, color: .black, alignment: .left)
    let titleImageView: UIImageView = .makeImageView("groupIcon", contentMode: .scaleAspectFit)
    
    let subtitleLabel: UILabel = .createTitle(text: NSLocalizedString("Invite your family and friends to MISU Family to access each other's health", comment: ""), fontSize: 14, color: UIColor.black.withAlphaComponent(0.75), alignment: .left)
    
    let numberTextField = CustomPhoneNumberTF()
    
    let addButton: UIButton = .createCustom(title: NSLocalizedString("Add", comment: ""),
                                            color: UIColor.appDefault.red, fontSize: 16, textColor: .white,
                                            shadow: false, customContentEdgeInsets: true, setCustomCornerRadius: true)
    let cancelButton: UIButton = .createCustom(title: NSLocalizedString("Cancel", comment: ""),
                                               color: .white, fontSize: 16, textColor: UIColor.appDefault.red,
                                               shadow: false, customContentEdgeInsets: true, setCustomCornerRadius: true)
    
    let doneStackView: UIStackView = .createCustom([], axis: .vertical, distribution: .equalSpacing, spacing: 16)
    let doneImageView: UIImageView = .makeImageView("doneFamIcon", contentMode: .scaleAspectFit)
    let numberLabel: UILabel = .createTitle(text: "-", fontSize: 16, color: .lightGray, alignment: .center)
    let doneLabel: UILabel = .createTitle(text: NSLocalizedString("Invitation sent", comment: ""), fontSize: 24, color: .black, alignment: .center)
    
    var successCompletion: ((_ group: GroupModel?)->Void)? = nil
    
    var groupId: Int?
    var groupModel: GroupModel?
    var invitationModel: GroupInviteModel?
    
    init(groupId gi: Int? = nil, successCompletion sc: ((_ group: GroupModel?)->Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        successCompletion = sc
        groupId = gi
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension InviteUserToGroupVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
}



// MARK: - Actions
extension InviteUserToGroupVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func addButtonAction() {
        guard let phoneNumber = numberTextField.phoneNumber, numberTextField.isValidNumber else {
            numberTextField.alertAnimation()
            return
        }
        
        let number = numberTextField.phoneNumberKit.format(phoneNumber, toType: .e164)
        
        if groupId != nil {
            sendInvite(fullNumber: number)
        } else {
            createNew(fullNumber: number)
        }
    }
    
    func sendInvite(fullNumber: String) {
        prepareViewsBeforReqest(viewsToBlock: [numberTextField, skipButton], activityButton: addButton)
        GroupsManager.shared.invite(.init(members: [fullNumber])) {[self] (inviteOp, errorOp) in
            enableViewsAfterReqest()
            if let invite = inviteOp {
                invitationModel = invite
                print("sendInvite: \n\(invite)")
                DispatchQueue.main.async {
                    goToSuccess()
                }
            }
            
            if let error = errorOp {
                print("sendInvite ERROR: \n\(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
    
    func createNew(fullNumber: String, goToSuccess gts: Bool = true) {
        prepareViewsBeforReqest(viewsToBlock: [numberTextField, skipButton], activityButton: addButton)
        let numbers = fullNumber.isEmpty ? [] : [fullNumber]
        GroupsManager.shared.create(.init(name: "___", members: numbers)) {[self] (groupOp, errorOp) in
            enableViewsAfterReqest()
            if let group = groupOp {
                groupModel = group
                print("Group created: \n\(group)")
                DispatchQueue.main.async {
                    if gts { goToSuccess() }
                    else { doneAction() }
                }
            }
            
            if let error = errorOp {
                print("Group created ERROR: \n\(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
    
    func goToSuccess() {
        view.endEditing(true)
        view.subviews.forEach { sub in
            if sub == view.subviews.last {
                sub.animateFade(duration: 0.3) { [self] _ in
                    skipButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
                    addButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
                    addButton.removeTarget(nil, action: nil, for: .allEvents)
                    skipButton.removeTarget(nil, action: nil, for: .allEvents)
                    skipButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
                    addButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
                    if let numb = numberTextField.phoneNumber?.numberString {
                        numberLabel.text = numb
                    }
                    doneStackView.animateShow(duration: 0.3)
                    addButton.animateShow(duration: 0.3)
                    skipButton.animateShow(duration: 0.3)
                }
                return
            }
            sub.animateFade(duration: 0.3)
        }
    }
    
    @objc func doneAction() {
        dismiss(animated: true) { [self] in
            if groupId == nil {
                successCompletion?(groupModel)
            }
        }
    }
    
    @objc func skipButtonAction()  {
        if groupId == nil {
            createNew(fullNumber: "", goToSuccess: false)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func cancelButtonAction()  {
        dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        let const = (cancelButton.customBottomAnchorConstraint?.constant ?? 0) - keyboardFrame.height
        
        if let old = cancelButton.customBottomAnchorConstraint?.constant, abs(old) >= view.standart24Inset*2 { return }
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: const, duration: 0.1)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -view.standartInset, duration: 0.1)
    }
}



// MARK: - TextField Delegate
extension InviteUserToGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let underTF = textField as? UIUnderLinedTextField {
            underTF.setSelected()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let underTF = textField as? UIUnderLinedTextField, !(underTF.text?.isEmpty ?? true) {
            underTF.setUnSelected()
        }
    }
}



// MARK: - SetUp Views
extension InviteUserToGroupVC {
    func setUp() {
        view.backgroundColor = .white
        view.addEndEditTapRecognizer(cancelsTouchesInView: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let titleContainer: UIView = .createCustom()
        let titleCenterContainer: UIView = .createCustom()
        
        view.addSubview(skipButton)
        view.addSubview(titleContainer)
        view.addSubview(titleCenterContainer)
        titleCenterContainer.addSubview(titleLabel)
        titleCenterContainer.addSubview(titleImageView)
        titleCenterContainer.addSubview(subtitleLabel)
        view.addSubview(numberTextField)
        view.addSubview(addButton)
        view.addSubview(cancelButton)
        view.addSubview(doneStackView)
        
        skipButton.topAnchor.constraint(equalTo: view.topAnchor,
                                        constant: view.standart24Inset-skipButton.contentEdgeInsets.top).isActive = true
        skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                             constant: -(view.standart24Inset-skipButton.contentEdgeInsets.right)).isActive = true
        skipButton.addTarget(self, action: #selector(skipButtonAction), for: .touchUpInside)
        
        numberTextField.delegate = self
        numberTextField.withFlag = true
        numberTextField.withPrefix = true
        numberTextField.withDefaultPickerUI = true
        numberTextField.withExamplePlaceholder = true
        PhoneNumberKit.CountryCodePicker.forceModalPresentation = true
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        numberTextField.customCenterYAnchorConstraint = numberTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        numberTextField.customCenterYAnchorConstraint?.isActive = true
        numberTextField.customCenterYAnchorConstraint?.priority = .init(100)
        numberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standart24Inset).isActive = true
        numberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standart24Inset).isActive = true
        
        titleContainer.topAnchor.constraint(equalTo: skipButton.bottomAnchor).isActive = true
        titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleContainer.bottomAnchor.constraint(equalTo: numberTextField.topAnchor).isActive = true
        
        titleCenterContainer.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor).isActive = true
        titleCenterContainer.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor).isActive = true
        titleCenterContainer.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor).isActive = true
        titleCenterContainer.topAnchor.constraint(greaterThanOrEqualTo: titleContainer.topAnchor).isActive = true
        titleCenterContainer.bottomAnchor.constraint(lessThanOrEqualTo: titleContainer.bottomAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: titleCenterContainer.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: titleCenterContainer.leadingAnchor, constant: view.standartInset).isActive = true
        titleLabel.setContentHuggingPriority(.init(1001), for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        
        titleImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        titleImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: view.standartInset).isActive = true
        titleImageView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 0.6).isActive = true
        let twm = (titleImageView.image?.size.width ?? 0) / (titleImageView.image?.size.height ?? 1)
        titleImageView.widthAnchor.constraint(equalTo: titleImageView.heightAnchor, multiplier: twm).isActive = true
        
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: view.standartInset).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: titleCenterContainer.leadingAnchor, constant: view.standartInset).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: titleCenterContainer.trailingAnchor, constant: -view.standartInset).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: titleCenterContainer.bottomAnchor).isActive = true
        subtitleLabel.numberOfLines = 5
        
        cancelButton.customBottomAnchorConstraint = cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.standartInset)
        cancelButton.customBottomAnchorConstraint?.isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        addButton.customBottomAnchorConstraint = addButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -view.standartInset)
        addButton.customBottomAnchorConstraint?.isActive = true
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        addButton.topAnchor.constraint(greaterThanOrEqualTo: numberTextField.bottomAnchor, constant: view.standart24Inset).isActive = true
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        
        doneStackView.addArrangedSubview(doneImageView)
        doneStackView.addArrangedSubview(numberLabel)
        doneStackView.addArrangedSubview(doneLabel)
        doneStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        doneStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneStackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: view.standartInset).isActive = true
        doneStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        doneStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        doneStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -view.standartInset).isActive = true
        doneStackView.animateFade(duration: 0)
        doneImageView.heightAnchor.constraint(equalToConstant: view.standartInset*2).isActive = true
        doneImageView.widthAnchor.constraint(equalToConstant: view.standartInset*2).isActive = true
    }
}
