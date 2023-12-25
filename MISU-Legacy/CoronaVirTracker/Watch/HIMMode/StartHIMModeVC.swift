//
//  StartHIMModeVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 07.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class StartHIMModeVC: UIViewController {
    let cancelButton: UIButton = .createCustom(title: NSLocalizedString("Cancel", comment: ""),
                                               color: .clear, fontSize: 16, textColor: .white,
                                               shadow: false, setCustomCornerRadius: false)
    
    let sliderGallery: SliderWithPagesView = {
        let data = HIMInfoStruct.allCases.map { item -> SliderDataStruct in
            return .init(image: item.image, text: item.localizableText)
        }
        let sg = SliderWithPagesView(data: data)
        sg.translatesAutoresizingMaskIntoConstraints = false
        return sg
    }()
    
    let startButton: UIButton = .createCustom(title: NSLocalizedString("Next", comment: ""),
                                              color: .white, fontSize: 18,
                                              textColor: UIColor.appDefault.red)
    
    let doneStackView: UIStackView = .createCustom(axis: .vertical, spacing: 16)
    let doneImageView: UIImageView = .makeImageView("doneFamIcon", withRenderingMode: .alwaysTemplate, tintColor: .white)
    let doneLabel: UILabel = .createTitle(text: NSLocalizedString("Health intensive monitoring started", comment: ""), fontSize: 16, color: .white, alignment: .center)
    let timePikerView: UIPickerView = .createPickerView()
    let doneSubLabel: UILabel = .createTitle(text: NSLocalizedString("Health intensive monitoring started", comment: ""), fontSize: 14, color: .white, alignment: .center)
    
    var HIMIntervalRange: [Int] = [15, 30, 60, 120, 180]
    
    var startCompletion: ((_ start: Bool)->Void)? = nil
    var startCompletionFlag: Bool = false
    
    var isSelectingTime: Bool = false
    var isStartedVPN: Bool = false
    let pickerViewRowHeight: CGFloat = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24)
        lb.text = "42"
        lb.sizeToFit()
        return lb.frame.height + lb.standartInset
    }()
    
    init(startCompletion sc: ((_ start: Bool)->Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        startCompletion = sc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension StartHIMModeVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fireStartCompletion(success: false)
    }
}



extension StartHIMModeVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func startButtonAction() {
        //print("$$$ startButtonAction \(isStartedVPN) \(isSelectingTime)")
        if isStartedVPN {
            fireStartCompletion(success: true)
            dismiss(animated: true)
            return
        }
        
        if isSelectingTime {
            startVPN()
        }
        
        if HIMInfoStruct.allCases[safe: sliderGallery.currentPage] == .battery {
            selectTime()
        } else {
            sliderGallery.nextPage()
        }
    }
    
    func selectTime() {
        isSelectingTime = true
        startButton.setTitle(NSLocalizedString("Turn on", comment: ""), for: .normal)
        sliderGallery.animateFade(duration: 0.1)
        
        doneLabel.text = NSLocalizedString("Health parameters are updated once per:", comment: "")
        doneSubLabel.text = NSLocalizedString("minutes", comment: "")
        doneStackView.removeArrangedSubview(doneImageView)
        doneStackView.addArrangedSubview(doneLabel)
        doneStackView.addArrangedSubview(timePikerView)
        doneStackView.addArrangedSubview(doneSubLabel)
            
        timePikerView.animateShow(duration: 0.1)
        doneStackView.animateShow(duration: 0.1)
    }
    
    func startVPN() {
        _ = KeychainUtils.saveToSharedDeviceUpdateTime(HIMIntervalRange[safe: timePikerView.selectedRow(inComponent: 0)] ?? 15)
        prepareViewsBeforReqest(viewsToBlock: [cancelButton], UIViewsToBlock: [timePikerView], activityButton: startButton, activityButtonColor: .lightGray)
        WatchFakeVPNManager.shared.startFakeWPN { success, error in
            DispatchQueue.main.async {
                self.goToSuccess(success, error: error)
            }
            self.enableViewsAfterReqest()
            //print("### $$$ \(success) \(error)")
        }
    }
    
    func goToSuccess(_ success: Bool, error: String?) {
        isStartedVPN = success
        //print("$$$ goToSuccess \(isStartedVPN) \(success)")
        //if success {
        doneStackView.animateFade(duration: 0.1) { _ in
            DispatchQueue.main.async { [self] in
                doneStackView.removeArrangedSubview(timePikerView)
                timePikerView.animateFade(duration: 0.1)
                doneLabel.text = error ?? NSLocalizedString("Health Intensive Monitoring", comment: "")
                if success {
                    startButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
                    doneSubLabel.text = NSLocalizedString("Activated", comment: "")
                    doneImageView.image = UIImage(named: "doneFamIcon")?.withRenderingMode(.alwaysTemplate)
                } else {
                    startButton.setTitle(NSLocalizedString("Try again", comment: ""), for: .normal)
                    doneSubLabel.text = NSLocalizedString("NOT Activated", comment: "")
                    doneImageView.image = UIImage(named: "unsuccessIcon")?.withRenderingMode(.alwaysTemplate)
                }
                doneStackView.removeArrangedSubview(doneImageView)
                doneStackView.addArrangedSubview(doneImageView)
                doneStackView.addArrangedSubview(doneLabel)
                doneStackView.addArrangedSubview(doneSubLabel)
                doneStackView.animateShow(duration: 0.1)
            }
        }
        //}
    }
    
    @objc func cancelButtonAction() {
        fireStartCompletion(success: false)
        dismiss(animated: true)
    }
    
    func fireStartCompletion(success: Bool) {
        startCompletionFlag ? pass : startCompletion?(success)
        startCompletionFlag = true
    }
}



// MARK: - SetUp Views
extension StartHIMModeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return HIMIntervalRange.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerViewRowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .white
        label.text = String(HIMIntervalRange[safe: row] ?? 15)
        return label
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        _ = checkAfterInfoEdits()
//    }
}



// MARK: - SetUp Views
extension StartHIMModeVC {
    func setUp() {
        view.backgroundColor = UIColor.appDefault.red
        
        view.addSubview(cancelButton)
        view.addSubview(sliderGallery)
        view.addSubview(startButton)
        view.addSubview(doneStackView)
        view.addSubview(timePikerView)
        
        let topConst = view.standart24Inset-cancelButton.contentEdgeInsets.top
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topConst).isActive = true
        let trailingConst = -(view.standart24Inset-cancelButton.contentEdgeInsets.right)
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConst).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        
        sliderGallery.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sliderGallery.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sliderGallery.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standart24Inset).isActive = true
        sliderGallery.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standart24Inset).isActive = true
        sliderGallery.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: view.standart24Inset).isActive = true
        sliderGallery.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -view.standart24Inset).isActive = true
        
        startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.standart24Inset).isActive = true
        startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standart24Inset).isActive = true
        startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standart24Inset).isActive = true
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        
        //doneStackView.addArrangedSubview(doneImageView)
        doneLabel.numberOfLines = 5
        doneStackView.addArrangedSubview(doneLabel)
        doneStackView.addArrangedSubview(timePikerView)
        doneStackView.addArrangedSubview(doneSubLabel)
        doneStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        doneStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneStackView.topAnchor.constraint(greaterThanOrEqualTo: cancelButton.bottomAnchor, constant: view.standartInset).isActive = true
        doneStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        doneStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        doneStackView.bottomAnchor.constraint(lessThanOrEqualTo: startButton.topAnchor, constant: -view.standartInset).isActive = true
        doneStackView.animateFade(duration: 0)
        doneImageView.heightAnchor.constraint(equalToConstant: view.standartInset*3).isActive = true
        doneImageView.widthAnchor.constraint(equalToConstant: view.standartInset*3).isActive = true
        
        timePikerView.delegate = self
        timePikerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        timePikerView.heightAnchor.constraint(equalToConstant: view.standart24Inset*8).isActive = true
        timePikerView.animateFade(duration: 0)
    }
}
