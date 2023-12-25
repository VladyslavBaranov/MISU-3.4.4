//
//  FamilyDoctorСVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class FamilyDoctorСVCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    
    let mainStack: UIStackView = .createCustom(axis: .vertical, spacing: 8, alignment: .center)
    let mainImage: UIImageView = .makeImageView("notApprovedDocStatus", contentMode: .scaleAspectFill)
    let fullNameLabel: UILabel = .createTitle(text: "- -", fontSize: 16, color: .black, alignment: .center)
    let sendMassageButton: UIButton = .createCustom(title: NSLocalizedString("Message", comment: ""),
                                                    color: UIColor.appDefault.redNew, fontSize: 14,
                                                    customContentEdgeInsets: false)
    
    let selectFDImage: UIImageView = .makeImageView("personWhiteIcon", contentMode: .scaleAspectFill)
    let selectFamilyDoctorLabel: UILabel = UILabel.createTitle(text: NSLocalizedString("Add your family doctor", comment: ""), fontSize: 14, color: .white, alignment: .center)
    
    var doctorModel: UserModel? {
        didSet {
            showFamilyDoctor(doctorModel == nil)
            guard let doctor = doctorModel else { return }
            if let nm = doctor.doctor?.fullName, !nm.isEmpty {
                fullNameLabel.text = nm
            } else {
                fullNameLabel.text = "- -"
            }
            if let imgUrl = doctor.doctor?.imageURL {
                mainImage.setImage(url: imgUrl, defaultImageName: "notApprovedDocStatus")
            }
            ListDHManager.shared.getAllDoctors(onlyOneDoctor: doctor, one: true) { (doctorList, error) in
                if let newDoc = doctorList?.first {
                    DispatchQueue.main.async {
                        if let nm = newDoc.doctor?.fullName, !nm.isEmpty {
                            self.fullNameLabel.text = nm
                        } else {
                            self.fullNameLabel.text = "- -"
                        }
                        //self.self.fullNameLabel.text = newDoc.doctor?.fullName ?? "Full name"
                        
                        if let imgUrl = newDoc.doctor?.imageURL {
                            DispatchQueue.main.async {
                                self.mainImage.setImage(url: imgUrl, defaultImageName: "notApprovedDocStatus")
                            }
                        }
                    }
                }
                if let er = error {
                    ModalMessagesController.shared.show(message: er.message, type: .error)
                }
            }
        }
    }
    
    var isCurent: Bool? {
        didSet {
            guard let curr = isCurent else { return }
            
            if curr, mainStack.arrangedSubviews.count < 3 {
                mainStack.addArrangedSubview(sendMassageButton)
                sendMassageButton.animateShow(duration: 0)
            } else if !curr, mainStack.arrangedSubviews.count > 2 {
                mainStack.removeArrangedSubview(sendMassageButton)
                sendMassageButton.animateFade(duration: 0)
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    @objc func goToChat() {
        guard let recId = UCardSingleManager.shared.user.profile?.familyDoctor?.id else { return }
        guard let token = KeychainUtils.getCurrentUserToken() else { return }
        
        prepareViewsBeforReqest(activityButton: sendMassageButton)
        ChatManager.shared.create(token: token, createModel: CreateChat(receiverId: recId, isDoctor: true)) { (chatOp, error) in
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
    
    func showFamilyDoctor(_ show: Bool) {
        if show {
            selectFDImage.animateShow(duration: 0)
            selectFamilyDoctorLabel.animateShow(duration: 0)
            backgroundColor = UIColor.appDefault.red
            
            mainStack.animateFade(duration: 0)
        } else {
            selectFDImage.animateFade(duration: 0)
            selectFamilyDoctorLabel.animateFade(duration: 0)
            backgroundColor = .white
            
            mainStack.animateShow(duration: 0)
        }
        
        //mainImage.isHidden = !show
        //fullNameLabel.isHidden = !show
        //chatButton.isHidden = !show
        /*
        if show {
            mainImage.alpha = 1
            fullNameLabel.alpha = 1
            chatButton.alpha = 1
        } else {
            mainImage.alpha = 0.05
            fullNameLabel.alpha = 0.05
            chatButton.alpha = 0.05
        }
        chatButton.isEnabled = show
        selectFamilyDoctorLabel.isHidden = show
        */
    }
    
    private func initSetUp() {
        backgroundColor = UIColor.white
        setCustomCornerRadius()
        addCustomShadow()
        
        sendMassageButton.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
        
        setUpConstraints()
    }
    
    func setUpConstraints(cView: UIView? = nil) {
        let cView = cView ?? self
        cView.addSubview(mainStack)
        cView.addSubview(mainImage)
        cView.addSubview(sendMassageButton)
        cView.addSubview(fullNameLabel)
        
        cView.addSubview(selectFDImage)
        cView.addSubview(selectFamilyDoctorLabel)
        
        mainStack.leadingAnchor.constraint(equalTo: cView.leadingAnchor, constant: standartInset/2).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: cView.trailingAnchor, constant: -standartInset/2).isActive = true
        mainStack.topAnchor.constraint(equalTo: cView.topAnchor ,constant: standartInset/2).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: cView.bottomAnchor, constant: -standartInset/2).isActive = true
        
        cView.layoutIfNeeded()
        
        //let const = fullNameLabel.frame.height + sendMassageButton.frame.height + standartInset*2
        //mainImage.widthAnchor.constraint(equalToConstant: const).isActive = true
        //mainImage.heightAnchor.constraint(equalToConstant: const).isActive = true
        
        sendMassageButton.leadingAnchor.constraint(equalTo: cView.leadingAnchor, constant: standartInset/2).isActive = true
        sendMassageButton.trailingAnchor.constraint(equalTo: cView.trailingAnchor, constant: -standartInset/2).isActive = true
        
        mainImage.setContentCompressionResistancePriority(.init(100), for: .vertical)
        mainImage.setContentHuggingPriority(.init(100), for: .vertical)
        mainImage.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        mainImage.setContentHuggingPriority(.init(100), for: .horizontal)
        
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        
        mainStack.addArrangedSubview(mainImage)
        mainStack.addArrangedSubview(fullNameLabel)
        mainStack.addArrangedSubview(sendMassageButton)
        
        fullNameLabel.numberOfLines = 2
        /*
        mainImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        mainImage.topAnchor.constraint(equalTo: contentView.topAnchor ,constant: standartInset).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        
        fullNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        fullNameLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        fullNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset/2).isActive = true
        */
        
        selectFDImage.centerYAnchor.constraint(equalTo: cView.centerYAnchor).isActive = true
        selectFDImage.leadingAnchor.constraint(equalTo: cView.leadingAnchor, constant: standartInset/2).isActive = true
        selectFDImage.heightAnchor.constraint(equalToConstant: selectFamilyDoctorLabel.font.lineHeight*1.5).isActive = true
        selectFDImage.widthAnchor.constraint(equalToConstant: selectFamilyDoctorLabel.font.lineHeight*1.5).isActive = true
        
        selectFamilyDoctorLabel.numberOfLines = 3
        selectFamilyDoctorLabel.centerYAnchor.constraint(equalTo: cView.centerYAnchor).isActive = true
        selectFamilyDoctorLabel.leadingAnchor.constraint(equalTo: selectFDImage.trailingAnchor, constant: standartInset/4).isActive = true
        selectFamilyDoctorLabel.trailingAnchor.constraint(equalTo: cView.trailingAnchor, constant: -standartInset/2).isActive = true
        selectFamilyDoctorLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        selectFamilyDoctorLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        
        selectFDImage.animateFade(duration: 0)
        selectFamilyDoctorLabel.animateFade(duration: 0)
        
        sendMassageButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        sendMassageButton.addImage(name: "chatIconNew", renderAs: .alwaysTemplate, height: standartInset)
        sendMassageButton.tintColor = .white
        sendMassageButton.titleLabel?.lineBreakMode = .byTruncatingTail
        sendMassageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendMassageButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        /*
        chatButton.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        chatButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        var img = UIImage(named: "chatIconNew")
        let hImg = standartInset
        img = img?.scaleTo(CGSize(width: hImg*(img?.imageWidthToHeightMultiplier() ?? 1), height: hImg))
        sendMassageButton.setImage(img, for: .normal)
        sendMassageButton.tintColor = .white
        sendMassageButton.imageEdgeInsets = .zero
        sendMassageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendMassageButton.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
        sendMassageButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
         */
    }
    
    
    static func getHeight() -> CGFloat {
        let cell = FamilyDoctorСVCell()
        let vv = UIView.createCustom()
        cell.setUpConstraints(cView: vv)
        vv.layoutIfNeeded()
        return cell.standartInset*4 + (cell.fullNameLabel.frame.height + cell.sendMassageButton.frame.height)*2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainImage.cornerRadius = mainImage.frame.size.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

