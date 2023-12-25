//
//  GeneralInfoHospitalViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 14.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class GeneralInfoHospitalViewCell: CustomCVCell, RequestUIController {
    func uniqeKeyForStore() -> String? { return getAddress() }
    
    let mainImage: UIImageView = .makeImageView("hospitalIcon", contentMode: .scaleAspectFill)
    
    let mainStack: UIStackView = .createCustom(axis: .vertical, spacing: 16, alignment: .leading)
    let nameLabel: UILabel = .createTitle(text: "Name")
    let addressButton: UIButton = {
        let bt = UIButton.createCustom(title: "Address", color: .clear, textColor: .lightGray,
                                       shadow: false, tintColor: UIColor.appDefault.redNew)
        bt.contentEdgeInsets = .init(top: bt.contentEdgeInsets.top, left: 0,
                                     bottom: bt.contentEdgeInsets.bottom, right: 0)
        bt.addImage(name: "defaultRedHospitalIcon", height: bt.standartInset)
        bt.contentHorizontalAlignment = .left
        return bt
    }()
    let messageButton: UIButton = {
        let bt = UIButton.createCustom(title: NSLocalizedString("Message", comment: ""),
                                       color: UIColor.appDefault.redNew, shadow: true, tintColor: .white)
        bt.addImage(name: "chatIconNew", height: bt.standartInset)
        return bt
    }()
    
    var hospital: HospitalModel? {
        didSet {
            addressButton.addImage(name: "mapPinIcon", height: standart24Inset, position: .right)
            addressButton.addTarget(self, action: #selector(goToMap), for: .touchUpInside)
            
            nameLabel.text = hospital?.fullName ?? "Name"
            if let name = hospital?.fullName {
                controller()?.navigationItem.title = name
            }
            nameLabel.numberOfLines = 5
            addressButton.setTitle(hospital?.location?.getFullLocationStr(withName: true) ?? "Address", for: .normal)
            
            mainImage.contentMode = .scaleAspectFit
            addressButton.titleLabel?.numberOfLines = 8
            
            messageButton.isHidden = true
            nameLabel.isHidden = true
            mainStack.removeArrangedSubview(messageButton)
            mainStack.removeArrangedSubview(nameLabel)
        }
    }
    
    var doctorModel: UserModel? {
        didSet {
            addressButton.addTarget(self, action: #selector(goToHospital), for: .touchUpInside)
            nameLabel.text = NSLocalizedString("Position", comment: "")
            addressButton.setTitle(NSLocalizedString("Select hospital", comment: ""), for: .normal)
            
            if let docPost = doctorModel?.doctor?.docPost {
                nameLabel.text = docPost.name
            }
            
            /*
             if let location = doctorModel?.doctor?.hospital {
                 addressButton.setTitle(location.getFullLocationStr(), for: .normal)
             }
             */
            
            let image = ImageCM.shared.get(byLink: doctorModel?.doctor?.imageURL) { imageReq in
                DispatchQueue.main.async { self.mainImage.image = imageReq }
            }
            
            self.mainImage.image = image ?? UIImage(named: "notApprovedDocStatus")
            
            if let hospital = doctorModel?.doctor?.hospitalModel?.fullName {
                addressButton.setTitle(hospital, for: .normal)
                addressButton.titleLabel?.lineBreakMode = .byTruncatingTail
            }
            
            mainImage.addTapRecognizer(self, action: #selector(tapImageAction))
            
       }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    @objc func goToChat() {
        if doctorModel?.isCurrent == true {
            (controller() as? ProfileVC)?.showChatsListVC()
            return
        }
        
        guard let recId = doctorModel?.id else { return }
        guard let token = KeychainUtils.getCurrentUserToken() else { return }
        
        prepareViewsBeforReqest(activityButton: messageButton)
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
    
    @objc func tapImageAction() {
        guard let user = doctorModel, user.isCurrent else { return }
        let vc = SettingsVC(user: user, editPhoto: true)
        vc.hidesBottomBarWhenPushed = true
        controller()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToHospital() {
        guard let hosp = doctorModel?.doctor?.hospitalModel else {
            selectHospital()
            return
        }
        
        let vc = HospitalVC()
        vc.hospital = hosp
        vc.hidesBottomBarWhenPushed = true
        navigationController()?.pushViewController(vc, animated: true)
    }
    
    func selectHospital() {
        if !(doctorModel?.isCurrent ?? false) { return }
        
        let selectFamDocView = HospitalSelectView(frame: self.controller()?.view.frame ?? .zero)
        selectFamDocView.show { _ in
            (self.controller() as? ProfileVC)?.reloadUserProfile(request: false)
        }
        return
    }
    
    @objc func goToMap() {
        guard let coord = hospital?.location?.coordinate else { return }
        
        MapTaskSingletonManager.shared.setTask(coordinateToScale: coord)
        
        if controller()?.tabBarController?.selectedIndex == MainTabBarStructEnum.map.rawValue {
            self.navigationController()?.popViewController(animated: true)
        } else {
           controller()?.tabBarController?.selectedIndex = MainTabBarStructEnum.map.rawValue
        }
    }
    
    func initSetUp(pView: UIView? = nil) {
        contentView.backgroundColor = UIColor.white
        contentView.setRoundedParticly(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 25)
        contentView.addCustomShadow()
        
        let pView = pView ?? self
        pView.addSubview(mainImage)
        pView.addSubview(mainStack)
        
        mainStack.addArrangedSubview(nameLabel)
        mainStack.addArrangedSubview(addressButton)
        mainStack.addArrangedSubview(messageButton)
        mainStack.addSubview(messageButton)
        //messageButton.setContentHuggingPriority(.init(100), for: .vertical)
        messageButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        addressButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        mainImage.leadingAnchor.constraint(equalTo: pView.leadingAnchor, constant: standartInset).isActive = true
        mainImage.topAnchor.constraint(equalTo: pView.topAnchor, constant: standartInset).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: pView.bottomAnchor, constant: -standartInset).isActive = true
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        
        mainStack.topAnchor.constraint(equalTo: pView.topAnchor, constant: standartInset).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: pView.bottomAnchor, constant: -standartInset).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: pView.trailingAnchor, constant: -standartInset).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset).isActive = true
        
        mainImage.cornerRadius = mainImage.frame.height/2
        
        messageButton.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
    }
    
    static func getHeight(frame: CGRect) -> CGFloat {
        let cell = GeneralInfoHospitalViewCell(frame: frame)
        cell.nameLabel.sizeToFit()
        cell.messageButton.sizeToFit()
        cell.addressButton.sizeToFit()
        return cell.nameLabel.frame.height + cell.messageButton.frame.height +
               cell.addressButton.frame.height + cell.standartInset*4
    }
    
    override func getSize(cv: UICollectionView) -> CGSize {
        nameLabel.sizeToFit()
        messageButton.sizeToFit()
        addressButton.sizeToFit()
        let h = nameLabel.frame.height + messageButton.frame.height + addressButton.frame.height + standartInset*4
        return .init(width: cv.frame.width,
                     height: h)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainImage.cornerRadius = mainImage.frame.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
