//
//  FamilyDoctorViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class FamilyDoctorViewCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    
    var mainImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "defDocImage")
        img.clipsToBounds = true
        return img
    }()
    
    let fullNameLabel: UILabel = UILabel.createTitle(text: "Конончук Микола", fontSize: 18, color: .black)
    let selectFamilyDoctorLabel: UILabel = UILabel.createTitle(text: NSLocalizedString("Add your family doctor", comment: ""), fontSize: 16, color: .black, alignment: .center)
    
    let chatButton: UIButton = {
        let bt = UIButton(type: UIButton.ButtonType.roundedRect)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = UIColor.appDefault.red
        bt.setCustomCornerRadius()
        bt.addCustomShadow()
        
        bt.titleLabel?.textAlignment = .center
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        bt.setTitleColor(.white, for: .normal)
        bt.setTitle(NSLocalizedString("Message", comment: ""), for: .normal)
        
        bt.contentEdgeInsets = .init(top: bt.standartInset*0.75, left: bt.standartInset, bottom: bt.standartInset*0.75, right: bt.standartInset)
        bt.addTapCustomAnim()
        
        return bt
    }()
    
    var doctorModel: UserModel? {
        didSet {
            if let doctor = doctorModel {
                fullNameLabel.text = doctor.doctor?.fullName ?? "Full name"
                mainImage.image = ImageCM.shared.get(byLink: doctor.doctor?.imageURL) ?? UIImage(named: "notApprovedDocStatus")
                ListDHManager.shared.getAllDoctors(onlyOneDoctor: doctor, one: true) { (doctorList, error) in
                    if let newDoc = doctorList?.first {
                        DispatchQueue.main.async {
                            self.fullNameLabel.text = newDoc.doctor?.fullName ?? "Full name"
                            
                            let image = ImageCM.shared.get(byLink: newDoc.doctor?.imageURL) { imageReq in
                                DispatchQueue.main.async { self.mainImage.image = imageReq }
                            }
                            self.mainImage.image = image ?? UIImage(named: "patientDefImage")
                        }
                    }
                    
                    if let er = error {
                        ModalMessagesController.shared.show(message: er.message, type: .error)
                    }
                }
                showFamilyDoctor(true)
            } else {
                showFamilyDoctor(false)
            }
        }
    }
    
    var isCurent: Bool? {
        didSet {
            guard let curr = isCurent else { return }
            
            if curr {
                chatButton.isEnabled = true
                chatButton.backgroundColor = UIColor.appDefault.red
                chatButton.setTitleColor(.white, for: .normal)
            } else {
                chatButton.isEnabled = false
                chatButton.backgroundColor = UIColor.appDefault.lightGrey
                chatButton.setTitleColor(.lightGray, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = UIColor.white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        chatButton.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
        
        contentView.addSubview(mainImage)
        contentView.addSubview(chatButton)
        contentView.addSubview(fullNameLabel)
        contentView.addSubview(selectFamilyDoctorLabel)
        
        setUpConstraints()
    }
    
    @objc func goToChat() {
        guard let recId = UCardSingleManager.shared.user.profile?.familyDoctor?.id else { return }
        guard let token = KeychainUtils.getCurrentUserToken() else { return }
        
        prepareViewsBeforReqest(viewsToBlock: [chatButton])
        chatButton.startActivity(style: .medium)
        ChatManager.shared.create(token: token, createModel: CreateChat(receiverId: recId, isDoctor: true)) { (chatOp, error) in
            self.enableViewsAfterReqest()
            self.chatButton.stopActivity()
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
    
    func setUpConstraints() {
        mainImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        mainImage.topAnchor.constraint(equalTo: contentView.topAnchor ,constant: standartInset).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        
        fullNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        fullNameLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        fullNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset/2).isActive = true
        
        selectFamilyDoctorLabel.numberOfLines = 2
        selectFamilyDoctorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        selectFamilyDoctorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        selectFamilyDoctorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        chatButton.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        chatButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
    
    func showFamilyDoctor(_ show: Bool) {
        //mainImage.isHidden = !show
        //fullNameLabel.isHidden = !show
        //chatButton.isHidden = !show
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
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let cell = FamilyDoctorViewCell()
        let views = [cell.fullNameLabel, cell.chatButton]
        
        var height: CGFloat = (cell.standartInset/2) * CGFloat(views.count-1)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

