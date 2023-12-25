//
//  NameAgeRegistrationVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.09.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Parameters
class NameAgeRegistrationVC: UIViewController {
    let mainTitleLabel: UILabel = .createTitle(text: NSLocalizedString("Welcome", comment: ""), fontSize: 24, color: .black, alignment: .center)
    let subTitleLabel: UILabel = .createTitle(text: NSLocalizedString("Almost done, last questions", comment: ""), fontSize: 18, color: .lightGray, alignment: .center)
    
    let nameTextField: UIUnderLinedTextField = UIUnderLinedTextField()
    
    let nextButton: UIButton = .createCustom(title: NSLocalizedString("Next", comment: ""))
    
    let birthdayLabel: UILabel = .createTitle(text: NSLocalizedString("Your birthday:", comment: ""), fontSize: 18, color: .lightGray, alignment: .center)
    let datePiker: UIDatePicker = {
        let dtPiker = UIDatePicker()
        dtPiker.translatesAutoresizingMaskIntoConstraints = false
        dtPiker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            dtPiker.preferredDatePickerStyle = .wheels
        }
        dtPiker.maximumDate = Date()
        return dtPiker
    }()
    
    let sexPikerView: UIPickerView = .createPickerView()
    
    var userModel: UserModel
    
    init(user uModel: UserModel) {
        userModel = uModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads override
extension NameAgeRegistrationVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpTitles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sexPikerView.selectRow(SexEnum.allCases.firstIndex(of: .notSelected) ?? 0, inComponent: 0, animated: true)
    }
}



// MARK: - Button actions
extension NameAgeRegistrationVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func nextButtonAction() {
        if checkAfterInfoEdits() {
            guard let token = KeychainUtils.getCurrentUserToken() else { return }
            if let profParams = UCardSingleManager.shared.user.profile?.encodeForGeneralInfoRequest() {
                prepareViewsBeforReqest(viewsToBlock: [nextButton], UIViewsToBlock: [nameTextField, datePiker, sexPikerView])
                nextButton.startActivity(style: .medium)
                UserManager.shared.updatePatient(token, params: profParams, files: []) { (profOp, errorOp) in
                    self.enableViewsAfterReqest()
                    self.nextButton.stopActivity()
                    if let prof = profOp {
                        UCardSingleManager.shared.user.profile = prof
                        UCardSingleManager.shared.user.saveToUserDef()
                        ModalMessagesController.shared.show(message: "Success", type: .success)
                        DispatchQueue.main.async { self.navigationController?.popToRootViewController(animated: true) }
                    }
                    
                    if let er = errorOp {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                    }
                }
                return
            }
            
            if let docParam = UCardSingleManager.shared.user.doctor?.encodeForGeneralInfoRequest() {
                prepareViewsBeforReqest(viewsToBlock: [nextButton], UIViewsToBlock: [nameTextField, datePiker, sexPikerView])
                nextButton.startActivity(style: .medium)
                UserManager.shared.updateDoctor(token, params: docParam, files: []) { (docOp, errorOp) in
                    self.enableViewsAfterReqest()
                    self.nextButton.stopActivity()
                    if let doc = docOp {
                        UCardSingleManager.shared.user.doctor = doc
                        UCardSingleManager.shared.user.saveToUserDef()
                        ModalMessagesController.shared.show(message: "Success", type: .success)
                        DispatchQueue.main.async { self.navigationController?.popToRootViewController(animated: true) }
                    }
                    
                    if let er = errorOp {
                        ModalMessagesController.shared.show(message: er.getInfo(), type: .error)
                    }
                }
                return
            }
        }
    }
}



// MARK: - Other
extension NameAgeRegistrationVC {
    func checkAfterInfoEdits() -> Bool {
        var moveNext: Bool = true
        
        if let name = nameTextField.text, !name.isEmpty {
            UCardSingleManager.shared.user.profile?.name = name
            UCardSingleManager.shared.user.doctor?.fullName = name
        } else {
            nameTextField.animateShake(intensity: 5, duration: 0.3)
            moveNext = false
        }
        
        let calendar = NSCalendar.current
        let diffYers = calendar.dateComponents([.year], from: calendar.startOfDay(for: datePiker.date), to: calendar.startOfDay(for: Date()))
        if let dY = diffYers.year, dY > 1 {
            UCardSingleManager.shared.user.profile?.birthdayDate = datePiker.date
        }
        
        if let sx = SexEnum.allCases[safe: sexPikerView.selectedRow(inComponent: 0)], sx != .notSelected {
            switch sx {
            case .man:
                UCardSingleManager.shared.user.profile?.gender = .male
            case .woman:
                UCardSingleManager.shared.user.profile?.gender = .female
            default:
                break
            }
        }
        return moveNext
    }
}



// MARK: - UIPicker Delegate & DataSource
extension NameAgeRegistrationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SexEnum.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = String(SexEnum.allCases[row].localizeble)
        return label
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        _ = checkAfterInfoEdits()
//    }
}



// MARK: - UITextFieldDelegate
extension NameAgeRegistrationVC: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        _ = checkAfterInfoEdits()
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
    }
}



// MARK: - Views Set ups
extension NameAgeRegistrationVC {
    func setUpView() {
        view.addEndEditTapRecognizer()
        view.backgroundColor = .white
    }
    
    func setUpTitles() {
        let containerView: UIView = .init()
        let titleContainerView: UIView = .init()
        let titleCenterContainerView: UIView = .init()
        
        view.addSubview(containerView)
        view.addSubview(titleContainerView)
        titleContainerView.addSubview(titleCenterContainerView)
        titleCenterContainerView.addSubview(mainTitleLabel)
        titleCenterContainerView.addSubview(subTitleLabel)
        containerView.addSubview(nameTextField)
        containerView.addSubview(birthdayLabel)
        containerView.addSubview(datePiker)
        containerView.addSubview(sexPikerView)
        view.addSubview(nextButton)
        
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleContainerView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        
        titleCenterContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleCenterContainerView.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor).isActive = true
        titleCenterContainerView.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor).isActive = true
        titleCenterContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        titleCenterContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: nextButton.topAnchor).isActive = true
        //containerView.backgroundColor = .yellow
        
        mainTitleLabel.topAnchor.constraint(equalTo: titleCenterContainerView.topAnchor).isActive = true
        mainTitleLabel.centerXAnchor.constraint(equalTo: titleCenterContainerView.centerXAnchor).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: view.standartInset).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: titleCenterContainerView.centerXAnchor).isActive = true
        subTitleLabel.bottomAnchor.constraint(equalTo: titleCenterContainerView.bottomAnchor).isActive = true
        
        nameTextField.delegate = self
        nameTextField.placeholder = NSLocalizedString("Full Name", comment: "")
        nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        birthdayLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: view.standartInset*2).isActive = true
        birthdayLabel.leadingAnchor.constraint(equalTo: datePiker.leadingAnchor).isActive = true
        birthdayLabel.trailingAnchor.constraint(equalTo: datePiker.trailingAnchor).isActive = true
        
        datePiker.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: view.standartInset/2).isActive = true
        datePiker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        datePiker.heightAnchor.constraint(lessThanOrEqualToConstant: 144).isActive = true
        
        sexPikerView.delegate = self
        sexPikerView.topAnchor.constraint(equalTo: datePiker.bottomAnchor).isActive = true
        sexPikerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        sexPikerView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        sexPikerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        sexPikerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset*2).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset*2).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.standartInset).isActive = true
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        nextButton.setContentCompressionResistancePriority(.init(1001), for: .horizontal)
    }
}
