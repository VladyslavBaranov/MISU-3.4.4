//
//  GeneralInfoPatientViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum GeneralInfoPatientEnum: String, CaseIterable {
    case sex = "Sex"
    case age = "Age"
    case weight = "Weight"
    case height = "Height"
    
    var localized: String {
        get { return NSLocalizedString(self.rawValue, comment: "") }
    }
    
    var defaultValue: String {
        get { return "-" }
    }
    
    var index: Int {
        get { return GeneralInfoPatientEnum.allCases.firstIndex(of: self) ?? 0 }
    }
}

class GeneralInfoPatientViewCell: UICollectionViewCell {
    let containerView: UIView = .createCustom(bgColor: .clear)
    let mainImage: UIImageView = {
        let img = UIImageView.makeImageView("patientDefImage", contentMode: .scaleAspectFill)
        img.clipsToBounds = true
        return img
    }()
    
    let allUserInfoStack: UIStackView = .createCustom([], axis: .horizontal, distribution: .equalSpacing, spacing: 0)
    
    let userInfoStacks: [UIStackView] = {
        var st: [UIStackView] = []
        GeneralInfoPatientEnum.allCases.forEach { _ in
            st.append(.createCustom([], axis: .vertical, distribution: .fillProportionally, spacing: 8, alignment: .leading))
        }
        return st
    }()
    
    let titleInfoLabels: [UILabel] = {
        var st: [UILabel] = []
        GeneralInfoPatientEnum.allCases.forEach { info in
            st.append(.createTitle(text: info.localized, fontSize: 14, color: UIColor.appDefault.blackPrimary, alignment: .center))
        }
        return st
    }()
    
    let valueInfoLabels: [UILabel] = {
        var st: [UILabel] = []
        GeneralInfoPatientEnum.allCases.forEach { info in
            st.append(.createTitle(text: info.defaultValue, fontSize: 14, color: .lightGray, alignment: .right))
        }
        return st
    }()
    
    let addressIconImage: UIImageView = .makeImageView("locationPrfIcon")
    let addressButton: UIButton = .createCustom(title: NSLocalizedString("Location", comment: ""),
                                               color: .clear, fontSize: 14,
                                               textColor: .lightGray,
                                               shadow: false, customContentEdgeInsets: false,
                                               setCustomCornerRadius: false)
    
    let familyIconImage: UIImageView = .makeImageView("familyPrfIcon")
    let familyButton: UIButton = .createCustom(title: NSLocalizedString("Family access", comment: ""),
                                               color: .clear, fontSize: 14,
                                               textColor: UIColor.appDefault.blackPrimary,
                                               shadow: false, customContentEdgeInsets: false,
                                               setCustomCornerRadius: false)
    
    let familyImagesStackView: UIStackView = .createCustom([], axis: .horizontal, distribution: .fillEqually, spacing: -8, alignment: .center)
    let familyImagesViews: [UIImageView] = {
        var iv: [UIImageView] = []
        (0..<GeneralInfoPatientViewCell.maxNumberOfFamImages).forEach { _ in
            iv.append(.makeImageView("patientDefImage", contentMode: .scaleAspectFill))
        }
        return iv
    }()
    static let maxNumberOfFamImages: Int = 8
    let sendMassageButton: UIButton = .createCustom(title: NSLocalizedString("Message", comment: ""), fontSize: 14)
    
    let statusImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.image = HealthStatus.well.new.getSmileImage()
        img.clipsToBounds = true
        return img
    }()
    
    var userModel: UserModel? {
        didSet {
            guard let profile = userModel?.profile else { return }
            
            if let age = profile.birthdayDate?.getYears() {
                valueInfoLabels[safe: GeneralInfoPatientEnum.age.index]?.text = String(age)
            } else {
                valueInfoLabels[safe: GeneralInfoPatientEnum.age.index]?.text = GeneralInfoPatientEnum.age.defaultValue
            }
            valueInfoLabels[safe: GeneralInfoPatientEnum.sex.index]?.text = profile.gender.localized
            valueInfoLabels[safe: GeneralInfoPatientEnum.weight.index]?.text = "\(profile.weight?.truncate(places: 1) ?? 0)"
            valueInfoLabels[safe: GeneralInfoPatientEnum.height.index]?.text = "\(profile.height?.truncate(places: 1) ?? 0)"
            if let img = profile.status?.new.getSmileImage() {
                statusImage.image = img
            } else {
                statusImage.image = HealthStatus.well.new.getSmileImage()
            }
            
            if let location = userModel?.location {
                addressButton.setTitle(NSLocalizedString(location.getFullLocationStr(), comment: ""), for: .normal)
            } else {
                addressButton.setTitle(NSLocalizedString("Location", comment: ""), for: .normal)
            }
            
            let image = ImageCM.shared.get(byLink: profile.imageURL) { imageReq in
                DispatchQueue.main.async { self.mainImage.image = imageReq }
            }
            self.mainImage.image = image ?? UIImage(named: "patientDefImage")
            
            if userModel?.isCurrent == true || UCardSingleManager.shared.user.id == userModel?.id {
                //sendMassageButton.animateFade(duration: 0.1)
                sendMassageButton.setImage(nil, for: .normal)
                sendMassageButton.setTitle(NSLocalizedString("Family access", comment: ""), for: .normal)
                sendMassageButton.removeAllTargets()
                sendMassageButton.addTarget(self, action: #selector(familyButtonAction), for: .touchUpInside)
            } else {
                //sendMassageButton.animateShow(duration: 0.1)
                sendMassageButton.addImage(name: "chatIconNew", renderAs: .alwaysTemplate, height: standartInset)
                sendMassageButton.tintColor = .white
                sendMassageButton.setTitle(NSLocalizedString("Message", comment: ""), for: .normal)
                sendMassageButton.removeAllTargets()
                sendMassageButton.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
            }
            isFamilyButtonEnable = userModel?.isCurrent ?? false
            guard let isCurrent = userModel?.isCurrent, isCurrent else { return }
            GroupsSingleManager.shared.delegate = self
            setUpFamilyGroup()
        }
    }
    
    var isFamilyButtonEnable: Bool {
        didSet {
            familyButton.isEnabled = isFamilyButtonEnable
            familyIconImage.image = familyIconImage.image?.withRenderingMode(isFamilyButtonEnable ? .alwaysOriginal : .alwaysTemplate)
        }
    }
    
    override init(frame: CGRect) {
        isFamilyButtonEnable = false
        super.init(frame: frame)
        
        initSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpFamilyGroup() {
        //print("### setUpFamilyGroup \(GroupsSingleManager.shared.groups)")
        guard let group = GroupsSingleManager.shared.groups.first,
              !group.members.isEmpty else {
            familyButton.animateShow(duration: 0.1)
            familyImagesStackView.animateFade(duration: 0.1)
            familyIconImage.image = UIImage(named: "familyPrfIcon")
            return
        }
        
        group.allMembers.enumerated().forEach { index, user in
            guard index < GeneralInfoPatientViewCell.maxNumberOfFamImages else { return }
            if let imgLink = user.profile?.imageURL ?? user.doctor?.imageURL {
                familyImagesViews[safe: index]?.setImage(url: imgLink, defaultImageName: "patientDefImage")
                familyImagesViews[safe: index]?.animateShow(duration: 0.1)
            }
        }
        
        familyIconImage.image = UIImage(named: "groupIcon")
        familyButton.animateFade(duration: 0.1)
        familyImagesStackView.animateShow(duration: 0.1)
    }
    
    @objc func tapImageAction() {
        guard let user = userModel, user.isCurrent else { return }
        let vc = SettingsVC(user: user, editPhoto: true)
        vc.hidesBottomBarWhenPushed = true
        controller()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToMap() {
        if !(userModel?.isCurrent ?? false) { return }
        let citySelector = CitySelectorModalView(frame: self.controller()?.view.frame ?? .zero)
        citySelector.show { location in
            self.userModel?.location = location
            UCardSingleManager.shared.user.location = location
            UCardSingleManager.shared.createLocation(location: location)
            DispatchQueue.main.async { (self.controller() as? ProfileVC)?.reloadUserProfile(request: false) }
        }
    }
    
    @objc func familyButtonAction() {
        if userModel?.isCurrent != true { return }
        GroupsSingleManager.shared.familyProfileButtonAction(self.controller())
    }
    
    @objc func goToChat() {
        guard let recId = userModel?.profile?.id else { return }
        guard let token = KeychainUtils.getCurrentUserToken() else { return }
        
        prepareViewsBeforReqest(activityButton: sendMassageButton)
        ChatManager.shared.create(token: token, createModel: CreateChat(receiverId: recId, isDoctor: false)) { (chatOp, error) in
            self.enableViewsAfterReqest()
            guard let chat = chatOp else { return }
            DispatchQueue.main.async {
                let ch = ChatsSinglManager.shared.getChatBy(id: chat.id ?? -123)
                if ch == nil {
                    ChatsSinglManager.shared.setChat(chat)
                }
                let vc = ChatVC(chat: ch ?? chat)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController()?.pushViewController(vc, animated: true)
            }
        }
    }
}



// MARK: - SetUp
extension GeneralInfoPatientViewCell: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return getAddress()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = UIColor.white
        contentView.setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 25)
        contentView.addCustomShadow()
        
        addressButton.addTarget(self, action: #selector(goToMap), for: .touchUpInside)
        familyButton.addTarget(self, action: #selector(familyButtonAction), for: .touchUpInside)
        
        contentView.addSubview(containerView)
        containerView.addSubview(mainImage)
        containerView.addSubview(statusImage)
        containerView.addSubview(allUserInfoStack)
        containerView.addSubview(familyButton)
        containerView.addSubview(familyIconImage)
        containerView.addSubview(addressButton)
        containerView.addSubview(addressIconImage)
        containerView.addSubview(familyImagesStackView)
        containerView.addSubview(sendMassageButton)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: standartInset).isActive = true
        
        mainImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standartInset).isActive = true
        mainImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: standartInset).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: addressButton.bottomAnchor).isActive = true
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        mainImage.addTapRecognizer(self, action: #selector(tapImageAction))
        
        statusImage.trailingAnchor.constraint(equalTo: mainImage.trailingAnchor).isActive = true
        statusImage.bottomAnchor.constraint(equalTo: mainImage.bottomAnchor).isActive = true
        statusImage.heightAnchor.constraint(equalToConstant: standartInset*1.8).isActive = true
        statusImage.widthAnchor.constraint(equalToConstant: standartInset*1.8).isActive = true
        
        titleInfoLabels.first?.sizeToFit()
        valueInfoLabels.first?.sizeToFit()
        let fsH: CGFloat = (titleInfoLabels.first?.frame.height ?? 0) + (userInfoStacks.first?.spacing ?? 0) + (valueInfoLabels.first?.frame.height ?? 0)
        allUserInfoStack.heightAnchor.constraint(equalToConstant: fsH).isActive = true
        allUserInfoStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standartInset).isActive = true
        allUserInfoStack.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        allUserInfoStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -standartInset).isActive = true
        allUserInfoStack.setContentHuggingPriority(.init(1001), for: .vertical)
        allUserInfoStack.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        
        GeneralInfoPatientEnum.allCases.forEach { info in
            if let infoStack = userInfoStacks[safe: info.index] {
                if let tt = titleInfoLabels[safe: info.index] {
                    infoStack.addArrangedSubview(tt)
                }
                if let vl = valueInfoLabels[safe: info.index] {
                    infoStack.addArrangedSubview(vl)
                }
                allUserInfoStack.addArrangedSubview(infoStack)
            }
        }
        
        addressButton.topAnchor.constraint(equalTo: allUserInfoStack.bottomAnchor, constant: standartInset).isActive = true
        addressButton.leadingAnchor.constraint(equalTo: addressIconImage.trailingAnchor, constant: standartInset/2).isActive = true
        addressButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -standartInset).isActive = true
        addressButton.setContentHuggingPriority(.init(1001), for: .vertical)
        addressButton.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        //addressButton.setContentCompressionResistancePriority(.init(99), for: .horizontal)
        addressButton.contentHorizontalAlignment = .leading
        addressIconImage.centerYAnchor.constraint(equalTo: addressButton.centerYAnchor).isActive = true
        addressIconImage.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        addressIconImage.heightAnchor.constraint(equalTo: addressButton.heightAnchor, multiplier: 0.7).isActive = true
        let awm = (addressIconImage.image?.size.width ?? 0) / (addressIconImage.image?.size.height ?? 1)
        addressIconImage.widthAnchor.constraint(equalTo: addressIconImage.heightAnchor, multiplier: awm).isActive = true
        addressIconImage.addTapRecognizer(self, action: #selector(goToMap))
        
        familyButton.contentEdgeInsets = .init(top: standartInset/4, left: 0, bottom: standartInset/4, right: 0)
        familyButton.leadingAnchor.constraint(equalTo: familyIconImage.trailingAnchor, constant: standartInset/2).isActive = true
        familyButton.trailingAnchor.constraint(equalTo: sendMassageButton.leadingAnchor, constant: -standartInset).isActive = true
        familyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -standart24Inset).isActive = true
        familyButton.setContentHuggingPriority(.init(1001), for: .vertical)
        familyButton.setContentCompressionResistancePriority(.init(1001), for: .vertical)
        familyButton.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        familyButton.contentHorizontalAlignment = .leading
        familyButton.setTitleColor(.lightGray, for: .disabled)
        familyIconImage.centerYAnchor.constraint(equalTo: familyButton.centerYAnchor).isActive = true
        familyIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: standart24Inset).isActive = true
        familyIconImage.heightAnchor.constraint(equalTo: familyButton.heightAnchor).isActive = true
        let fwm = (familyIconImage.image?.size.width ?? 0) / (familyIconImage.image?.size.height ?? 1)
        familyIconImage.widthAnchor.constraint(equalTo: familyIconImage.heightAnchor, multiplier: fwm).isActive = true
        familyIconImage.addTapRecognizer(self, action: #selector(familyButtonAction))
        familyIconImage.tintColor = .lightGray
        
        familyImagesStackView.centerYAnchor.constraint(equalTo: familyIconImage.centerYAnchor).isActive = true
        familyImagesStackView.leadingAnchor.constraint(equalTo: familyIconImage.trailingAnchor, constant: standartInset/2).isActive = true
        familyImagesStackView.trailingAnchor.constraint(lessThanOrEqualTo: sendMassageButton.leadingAnchor, constant: -standartInset).isActive = true
        
        familyImagesViews.forEach { imgView in
            familyImagesStackView.addArrangedSubview(imgView)
            imgView.heightAnchor.constraint(equalToConstant: standart24Inset).isActive = true
            imgView.widthAnchor.constraint(equalToConstant: standart24Inset).isActive = true
            imgView.cornerRadius = standart24Inset/2
            imgView.animateFade(duration: 0)
            imgView.addTapRecognizer(self, action: #selector(familyButtonAction))
        }
        
        familyImagesStackView.animateFade(duration: 0)
        
        sendMassageButton.centerYAnchor.constraint(equalTo: familyIconImage.centerYAnchor).isActive = true
        sendMassageButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -standartInset).isActive = true
        sendMassageButton.tintColor = .white
        sendMassageButton.titleLabel?.lineBreakMode = .byTruncatingTail
        sendMassageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        sendMassageButton.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
    }
    
    static func getHeight(frame: CGRect, insets: Bool = true) -> CGFloat {
        let cell = GeneralInfoPatientViewCell(frame: frame)
        let views = [cell.allUserInfoStack, cell.addressButton, cell.familyButton]
        
        var height: CGFloat = cell.standartInset * CGFloat(views.count-1) + 8
        
        cell.layoutIfNeeded()
        for v in views {
            v.sizeToFit()
            height += v.frame.height
        }
        
        if insets {
            height += cell.standartInset*2
        }
        
        return height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainImage.cornerRadius = mainImage.frame.size.height/2
    }
}



// MARK: - GeneralInfoPatientViewCell
extension GeneralInfoPatientViewCell: GroupsDelegate {
    func groupsDidUpdate(manager: GroupsSingleManager) {
        self.setUpFamilyGroup()
    }
    
    func groupDidDeleted() {
    }
}
