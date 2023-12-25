//
//  CovidRiscView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CovidRiscView: PresentUIViewController {
    let scrollView: UIScrollView = .create()
    let statusImage: UIImageView = .makeImageView(UIImage(named: "greyHealthSmile"))
    let statusLabel: UILabel = .createTitle(text: NSLocalizedString("Undefined", comment: ""),
                                            fontSize: 16, weight: .semibold, color: .gray,
                                            alignment: .center, numberOfLines: 2)
    let vaccineButton: UIButton = .createCustom(title: NSLocalizedString("Add vaccine", comment: ""), color: .lightGray, disabledTextColor: .white, btnType: .custom)
    let vaccinesListButton: UIButton = .createCustom(
        withImage: UIImage(named: "TabBar_Bookmark"), backgroundColor: .lightGray,
        contentEdgeInsets: .init(top: 12, left: 16, bottom: 12, right: 16),
        tintColor: .white, imageRenderingMode: .alwaysTemplate, partCornerRadius: false, cornerRadius: 10)
    let mainStack: UIStackView = .createCustom(axis: .vertical, spacing: 36, alignment: .center)
    let paramsStack: UIStackView = .createCustom(axis: .vertical, spacing: 24, alignment: .leading)
    let recomendationButton: UIButton = .createCustom(title: NSLocalizedString("Recommendation", comment: ""), color: UIColor.appDefault.redNew, fontSize: 14, shadow: false, btnType: .custom)
    
    var pId: Int?
    
    let editViews: [CovidRiscStruct:UIView] = {
        var sv: [CovidRiscStruct:UIView] = [:]
        CovidRiscStruct.allCases.forEach { cCase in
            guard let vv = cCase.editView else { return }
            sv.updateValue(vv, forKey: cCase)
        }
        return sv
    }()
    
    var statusBGViews: [CovidRiscStruct:UIView] = {
        return CovidRiscStruct.allCases.reduce(into: [CovidRiscStruct:UIView]()) { dict, ccase in
            dict.updateValue(.createCustom(bgColor: .white, cornerRadius: 24), forKey: ccase)
        }
    }()
    
    let statusViews: [CovidRiscStruct:UILabel] = {
        var sv: [CovidRiscStruct:UILabel] = [:]
        CovidRiscStruct.allCases.forEach { cCase in
            guard let sl = cCase.statusLabel else { return }
            sv.updateValue(sl, forKey: cCase)
        }
        return sv
    }()
    
    var paramsStackViews: [CovidRiscStruct:UIStackView] = [:]
    
    let editDefaultTitle = NSLocalizedString("Edit", comment: "")
    let editVaccineDefaultTitle = NSLocalizedString("Add vaccine", comment: "")
    var covidInfo: CovidModel = .init() {
        didSet {
            statusImage.image = covidInfo.riskGroup.image
            statusLabel.text = covidInfo.riskGroup.localizedForView
            statusLabel.textColor = covidInfo.riskGroup.color
            
            statusViews[.age]?.text = covidInfo.age?.statusTitleText ?? "?"
            statusViews[.age]?.textColor = covidInfo.age?.status.colorForStatusLabel ?? RiskGroup.undefined.colorForStatusLabel
            statusBGViews[.age]?.backgroundColor = covidInfo.age?.status.colorForStatusBG ?? RiskGroup.undefined.colorForStatusBG
            (covidInfo.age ?? .init()).status.addShadow(statusBGViews[.age])
            
            statusViews[.apn]?.text = RiskGroup(inGroup: covidInfo.syndrome).paramStatusTitle
            statusViews[.apn]?.textColor = RiskGroup(inGroup: covidInfo.syndrome).colorForStatusLabel
            statusBGViews[.apn]?.backgroundColor = RiskGroup(inGroup: covidInfo.syndrome).colorForStatusBG
            RiskGroup(inGroup: covidInfo.syndrome).addShadow(statusBGViews[.apn])
            
            statusViews[.sex]?.text = covidInfo.gender?.statusTitleText ?? "?"
            statusViews[.sex]?.textColor = covidInfo.gender?.status.colorForStatusLabel ?? RiskGroup.undefined.colorForStatusLabel
            statusBGViews[.sex]?.backgroundColor = covidInfo.gender?.status.colorForStatusBG ?? RiskGroup.undefined.colorForStatusBG
            (covidInfo.gender ?? .init()).status.addShadow(statusBGViews[.sex])
            
            statusViews[.index]?.text = covidInfo.body?.statusTitleText ?? "?"
            statusViews[.index]?.textColor = covidInfo.body?.status.colorForStatusLabel ?? RiskGroup.undefined.colorForStatusLabel
            statusBGViews[.index]?.backgroundColor = covidInfo.body?.status.colorForStatusBG ?? RiskGroup.undefined.colorForStatusBG
            (covidInfo.body ?? .init()).status.addShadow(statusBGViews[.index])
            
            (editViews[.weight] as? UITextField)?.text = covidInfo.body?.weight?.getStrValue()
            (editViews[.height] as? UITextField)?.text = covidInfo.body?.height?.getStrValue()
            (editViews[.index] as? UILabel)?.text = covidInfo.body?.imt?.getStrValue() ?? NSLocalizedString("Input your weight and Height", comment: "")
            (editViews[.age] as? UIButton)?.setTitle(covidInfo.age?.ageValue ?? editDefaultTitle, for: .normal)
            (editViews[.sex] as? UIButton)?.setTitle(covidInfo.gender?.sexValue ?? editDefaultTitle, for: .normal)
            (editViews[.apn] as? UIButton)?.setTitle(covidInfo.syndromStr ?? editDefaultTitle, for: .normal)
            
            let vacName = covidInfo.vaccines.first?.name ?? covidInfo.vaccine?.name ?? editVaccineDefaultTitle
            let vacDate = covidInfo.vaccines.first?.date?.getDate() ?? covidInfo.vaccine?.date?.getDate() ?? ""
            vaccineButton.setTitle(vacName + ": " + vacDate, for: .normal)
            vaccineButton.backgroundColor = (covidInfo.vaccines.first ?? covidInfo.vaccine) == nil ? .lightGray : UIColor.appDefault.green
            
            editedCovidInfo = .init(height: covidInfo.body?.height,
                                    weight: covidInfo.body?.weight,
                                    gender: covidInfo.gender?.value,
                                    syndrome: covidInfo.syndrome,
                                    vaccine: covidInfo.vaccine)
        }
    }
    var parentCell: CovidRiscCVCell?
    
    var editedCovidInfo: CovidModel = .init() {
        didSet {
            print("Edited")
        }
    }
}



// MARK: - View Loads
extension CovidRiscView {
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        
        if pId == nil { return }
        editViews.forEach({ ($0.value as? UIControl)?.isEnabled = false })
        paramsStackViews.forEach({ $0.value.gestureRecognizers?.first?.isEnabled = false })
        vaccineButton.isEnabled = false
    }
}

extension CovidRiscView: RequestUIController {
    func uniqeKeyForStore() -> String? { return view.getAddress() }
    
    func getInfo() {
        CovidManager.shared.getInfo(uid: pId) { covidInfo_, error_ in
            if let ci = covidInfo_?.first, self.covidInfo != ci {
                DispatchQueue.main.async {
                    self.covidInfo = ci
                    self.parentCell?.covidInfo = ci
                }
            }
            if let er = error_ {
                print("Get covid risk ERROR: \(er)")
            }
        }
    }
}



// MARK: - Edits
extension CovidRiscView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.count ?? 0) > 10 {
            textField.animateShake(intensity: 5, duration: 0.3)
            return
        }
        let value = Double(textField.text?.replacingOccurrences(of: ",", with: ".") ?? "")?.truncate(places: 1)
        if value == nil, textField.text?.isEmpty == false {
            textField.animateShake(intensity: 5, duration: 0.3)
            return
        }
        
        switch textField {
        case editViews[.weight]:
            if value == covidInfo.body?.weight { return }
            editedCovidInfo.body?.weight = value
            update()
        case editViews[.height]:
            if value == covidInfo.body?.height { return }
            editedCovidInfo.body?.height = value
            update()
        default:
            print("Unknown textField edited ...")
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        switch sender {
        case editViews[.age]:
            let vw = AgeEditView(frame: view.frame)
            vw.selectedDate = covidInfo.age?.valueStr?.toDate() ?? Date()
            vw.show { save in
                if !save { return }
                if self.covidInfo.age?.valueStr?.toDate()?.isSameDay(with: vw.selectedDate) == true || vw.selectedDate.isSameDay(with: Date()) { return }
                self.editedCovidInfo.birth_date = vw.selectedDate
                self.update()
            }
        case editViews[.sex]:
            let vw = SexEditView(frame: view.frame)
            if let sexInt = covidInfo.gender?.value {
                vw.selectedSex = SexEnum(num: sexInt)
            } else {
                vw.selectedSex = SexEnum.notSelected
            }
            vw.show { save in
                if !save { return }
                if vw.selectedSex.valueForRequest == self.covidInfo.gender?.value { return }
                self.editedCovidInfo.gender?.value = vw.selectedSex.valueForRequest
                self.update()
            }
        case editViews[.apn]:
            let vw = SyndromAPNEditView(frame: view.frame)
            vw.show { save in
                if !save { return }
                if vw.isAPNSyndr == self.covidInfo.syndrome { return }
                self.editedCovidInfo.syndrome = vw.isAPNSyndr
                self.update()
            }
        case vaccineButton:
            let vw = VaccinesEditView(frame: view.frame)
            vw.show(parentView: self.view) { save in
                if !save { return }
                if vw.selectedVaccine == (self.covidInfo.vaccines.first ?? self.covidInfo.vaccine) { return }
                self.editedCovidInfo.vaccine = vw.selectedVaccine
                self.update()
            }
        case vaccinesListButton:
            let vc = VaccinesListVC()
            vc.vaccinesList = covidInfo.vaccines
            present(vc, animated: true)
        default:
            print("Unknown button taped ...")
        }
    }
    
    func update() {
        CovidManager.shared.update(model: editedCovidInfo) { covidInfo_, error_ in
            if covidInfo_ != nil {//let ci = covidInfo_ {
                ModalMessagesController.shared.show(message: NSLocalizedString("Information is updated", comment: ""), type: .success)
                DispatchQueue.main.async {
                    self.getInfo()
                }
            }
            
            if let er = error_ {
                print("Update covid risk ERROR: \(er)")
                ModalMessagesController.shared.show(message: er.message, type: .error)
            }
        }
    }
    
    @objc func stackTapAction(_ sender: UITapGestureRecognizer) {
        switch sender.view {
        case paramsStackViews[.weight]:
            editViews[.weight]?.becomeFirstResponder()
        case paramsStackViews[.height]:
            editViews[.height]?.becomeFirstResponder()
        case paramsStackViews[.index]:
            let vc = CovidRecommandationVC()
            vc.infoType = .bodyIndex
            self.present(vc, animated: true)
        case paramsStackViews[.age]:
            guard let btn = (editViews[.age] as? UIButton) else { return }
            buttonAction(btn)
        case paramsStackViews[.sex]:
            guard let btn = (editViews[.sex] as? UIButton) else { return }
            buttonAction(btn)
        case paramsStackViews[.apn]:
            guard let btn = (editViews[.apn] as? UIButton) else { return }
            buttonAction(btn)
        default:
            print("Unknown StackView taped ...")
        }
    }
    
    @objc func statusTapAction(_ sender: UITapGestureRecognizer) {
        var txt: String? = nil
        switch sender.view {
        case statusBGViews[.index]:
            txt = covidInfo.body?.status.statusText
        case statusBGViews[.age]:
            txt = covidInfo.age?.status.statusText
        case statusBGViews[.sex]:
            txt = covidInfo.gender?.status.statusText
        case statusBGViews[.apn]:
            txt = RiskGroup(inGroup: covidInfo.syndrome).statusText
        default:
            print("Unknown Status View taped ...")
        }
        SmallMessageView().showOn(view, anchorView: sender.view ?? view, text: txt ?? RiskGroup.undefined.statusText)
    }
    
    @objc func recomendationButtonAction() {
        let vc = CovidRecommandationVC()
        vc.infoType = covidInfo.result == true ? .inRisk : .noRisk
        self.present(vc, animated: true)
    }
}



// MARK: - Set Ups
extension CovidRiscView {
    override func setUp() {
        super.setUp()
        view.backgroundColor = UIColor.appDefault.lightGrey
        view.addEndEditTapRecognizer()
        view.addSubview(scrollView)
        cancelButton.removeFromSuperview()
        scrollView.addSubview(mainStack)
        
        //let statusLablBtnStack = UIStackView.createCustom([statusLabel, statusImage], axis: .horizontal, alignment: .center)
        let vacStack = UIStackView.createCustom([vaccineButton, vaccinesListButton])
        vaccinesListButton.setContentCompressionResistancePriority(.init(100), for: .vertical)
        vaccinesListButton.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        vaccinesListButton.heightAnchor.constraint(equalTo: vaccineButton.heightAnchor).isActive = true
        vaccinesListButton.widthAnchor.constraint(equalTo: vaccineButton.heightAnchor, multiplier: 1.3).isActive = true
        let statusStack = UIStackView.createCustom([statusLabel, vacStack], axis: .vertical, spacing: view.standartInset*2)
        let bgView = UIView.createCustom(bgColor: .white, cornerRadius: 15)
        bgView.addCustomShadow()
        view.addSubview(bgView)
        view.sendSubviewToBack(bgView)
        bgView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        mainStack.addArrangedSubview(statusStack)
        bgView.bottomAnchor.constraint(equalTo: statusStack.bottomAnchor, constant: view.standart24Inset).isActive = true
        
        statusStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        vaccineButton.widthAnchor.constraint(equalTo: statusStack.widthAnchor, multiplier: 0.7).isActive = true
        
        statusImage.widthAnchor.constraint(equalToConstant: statusLabel.font.lineHeight).isActive = true
        statusImage.heightAnchor.constraint(equalToConstant: statusLabel.font.lineHeight).isActive = true
        vaccineButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        vaccineButton.addImage(name: "vaccineIcon", renderAs: .alwaysOriginal, height: vaccineButton.titleLabel?.font.lineHeight)
        vaccinesListButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.contentSize = .zero
        
        mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.standart24Inset).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: view.standartInset).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -view.standartInset).isActive = true
        mainStack.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -view.standart24Inset).isActive = true
        
        mainStack.addArrangedSubview(paramsStack)
        paramsStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        CovidRiscStruct.allCases.forEach { cCase in
            var eviews: [UIView] = [cCase.titleLabel]
            if let ed = editViews[cCase] {
                (ed as? UITextField)?.delegate = self
                (ed as? UIButton)?.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
                if cCase == .index {
                    eviews.append(ed)
                } else {
                    let stV = UIStackView.createCustom([UIImageView.makeImageView(UIImage(named: "editImg")?.scaleTo(10)), ed])
                    eviews.append(stV)
                }
            }
            let textStack = UIStackView.createCustom(eviews, axis: .vertical, spacing: 4, alignment: .leading)
            
            var aviews: [UIView] = [cCase.iconView, textStack]
            if let label = statusViews[cCase] {
                label.widthAnchor.constraint(equalToConstant: view.standart24Inset).isActive = true
                
                statusBGViews[cCase]?.widthAnchor.constraint(equalToConstant: view.standart24Inset*2).isActive = true
                statusBGViews[cCase]?.heightAnchor.constraint(equalToConstant: view.standart24Inset*2).isActive = true
                statusBGViews[cCase]?.addSubview(label)
                statusBGViews[cCase]?.addTapRecognizer(self, action: #selector(statusTapAction(_:)))
                if let bgv = statusBGViews[cCase] {
                    label.centerXAnchor.constraint(equalTo: bgv.centerXAnchor).isActive = true
                    label.centerYAnchor.constraint(equalTo: bgv.centerYAnchor).isActive = true
                    aviews.append(bgv)
                }
            }
            let stack = UIStackView.createCustom(aviews, distribution: .fill)
            paramsStack.addArrangedSubview(stack)
            paramsStackViews.updateValue(stack, forKey: cCase)
            stack.widthAnchor.constraint(equalTo: paramsStack.widthAnchor).isActive = true
            stack.addTapRecognizer(self, action: #selector(stackTapAction(_:)))
        }
        mainStack.addArrangedSubview(recomendationButton)
        recomendationButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.8).isActive = true
        recomendationButton.addImage(name: "paperIcon", renderAs: .alwaysOriginal, height: view.standart24Inset)
        recomendationButton.addTarget(self, action: #selector(recomendationButtonAction), for: .touchUpInside)
        recomendationButton.addShadow(radius: 10, offset: .init(width: 0, height: 15), opacity: 0.2, color: UIColor.appDefault.redNew)
    }
}
