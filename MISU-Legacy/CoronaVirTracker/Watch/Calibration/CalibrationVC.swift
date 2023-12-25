//
//  CalibrationVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 24.05.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CalibrationVC: UIViewController {
    let cancelButton: UIButton = .createCustom(title: NSLocalizedString("Cancel", comment: ""),
                                               color: .clear, fontSize: 16, textColor: UIColor.appDefault.redNew,
                                               shadow: false, setCustomCornerRadius: false)
    
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Pressure calibration", comment: "") , fontSize: 20,
                                           weight: .bold, alignment: .center)
    
    var sliderGallery: SliderWithPagesNewView = {
        let sg = SliderWithPagesNewView(data: [])
        sg.translatesAutoresizingMaskIntoConstraints = false
        sg.pageController.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        sg.pageController.currentPageIndicatorTintColor = .gray
        return sg
    }()
    
    let tonomCalibView = TonomCalibView()
    let braceletCalibView = BraceletCalibView()
    var calibrationStatusView = CalibrationStatusView()
    
    let startButton: UIButton = .createCustom(title: NSLocalizedString("Next", comment: ""),
                                              color: UIColor.appDefault.redNew, fontSize: 16)
    
    var tonomHParams: HealthParameterModel?
    var braceletHParams: HealthParameterModel?
    
    var isCalibrated: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension CalibrationVC: DragDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sliderGallery.collectionView.reloadData()
    }
    
    func scrollDidDragWith(direction: DragAllDirection, scrollView: UIScrollView) {
    }
}



extension CalibrationVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func startButtonAction() {
        guard startButton.isEnabled else { return }
        switch sliderGallery.currentPage {
        case 0:
            guard let hParam = tonomCalibView.getIndicators() else {
                tonomCalibView.alertAnim()
                return
            }
            tonomHParams = hParam
            sliderGallery.endEditing(true)
            sliderGallery.nextPage()
        case 1:
            var isDone = false
            prepareViewsBeforReqest(activityButton: startButton)
            braceletCalibView.getIndicators { hp in
                isDone = true
                self.enableViewsAfterReqest()
                self.braceletHParams = hp
                DispatchQueue.main.async {
                    self.sliderGallery.nextPage()
                    self.sendCalibration()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if isDone { return }
                self.enableViewsAfterReqest()
                ModalMessagesController.shared.show(message: NSLocalizedString("Error, check data and try again ...", comment: ""), type: .error)
            }
        case 2:
            isCalibrated ? dismiss(animated: true) : pass
            sendCalibration()
        default:
            sliderGallery.nextPage()
        }
    }
    
    func sendCalibration() {
        guard let tonom = tonomHParams else { return }
        guard let bracelet = braceletHParams else { return }
        prepareViewsBeforReqest(activityButton: startButton)
        calibrationStatusView.sendCalibration(tonom: tonom, bracelet: bracelet) { (success, errText) in
            self.enableViewsAfterReqest()
            
            DispatchQueue.main.async {
                if success {
                    self.startButton.setTitle(NSLocalizedString("Done", comment: ""), for: [.normal, .disabled])
                    self.isCalibrated = true
                } else {
                    self.startButton.setTitle(NSLocalizedString("Try again", comment: ""), for: [.normal, .disabled])
                }
            }
        }
    }
    
    @objc func cancelButtonAction() {
        dismiss(animated: true)
    }
}



// MARK: - UITextField Delegate
extension CalibrationVC: UITextFieldDelegate {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        guard self.view.frame.origin.y == 0 else { return }
        self.view.frame.origin.y -= keyboardFrame.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard self.view.frame.origin.y != 0 else { return }
        self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tonomCalibView.firstTextField:
            tonomCalibView.secondTextField.becomeFirstResponder()
        default:
            textField.endEditing(true)
        }
        return true
    }
}



// MARK: - SetUp Views
extension CalibrationVC {
    func setUp() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addEndEditTapRecognizer(cancelsTouchesInView: true)
        view.backgroundColor = .white
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(sliderGallery)
        view.addSubview(startButton)
        
        let topConst = view.standart24Inset-cancelButton.contentEdgeInsets.top
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topConst).isActive = true
        let trailingConst = -(view.standart24Inset-cancelButton.contentEdgeInsets.right)
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConst).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        
        titleLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: view.standartInset).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tonomCalibView.firstTextField.delegate = self
        tonomCalibView.secondTextField.delegate = self
        sliderGallery.dataSource = [tonomCalibView, braceletCalibView, calibrationStatusView]
        sliderGallery.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sliderGallery.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sliderGallery.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standart24Inset).isActive = true
        sliderGallery.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standart24Inset).isActive = true
        sliderGallery.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: view.standart24Inset).isActive = true
        sliderGallery.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -view.standart24Inset).isActive = true
        sliderGallery.dragDelegate = self
        sliderGallery.collectionView.bounces = false
        sliderGallery.pageController.isUserInteractionEnabled = false
        sliderGallery.collectionView.isScrollEnabled = false
        
        startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.standart24Inset).isActive = true
        startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standart24Inset).isActive = true
        startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standart24Inset).isActive = true
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
    }
}

