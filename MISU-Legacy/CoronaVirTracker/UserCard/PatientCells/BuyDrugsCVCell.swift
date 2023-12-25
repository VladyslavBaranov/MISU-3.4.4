//
//  BuyDrugsCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 16.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class BuyDrugsCVCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    
    let mainStack: UIStackView = .createCustom(axis: .horizontal, spacing: 8, alignment: .center)
    let iconImage: UIImageView = .makeImageView("drugsWhiteIcon", contentMode: .scaleAspectFit)
    let textLabel: UILabel = .createTitle(text: NSLocalizedString("Order medicine", comment: ""), fontSize: 16,
                                          color: .white, alignment: .center)
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    @objc func goToChat() {
        guard let token = KeychainUtils.getCurrentUserToken() else { return }
        let drugsId = ChatsSinglManager.shared.drugsChatDocID
        
        prepareViewsBeforReqest(activityView: self)
        mainStack.animateFade(duration: 0.1)
        ChatManager.shared.create(token: token, createModel: CreateChat(receiverId: drugsId, isDoctor: true)) { (chatOp, error) in
            self.enableViewsAfterReqest()
            DispatchQueue.main.async { self.mainStack.animateShow(duration: 0.1) }
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
    
    private func initSetUp() {
        backgroundColor = UIColor.appDefault.redNew
        setCustomCornerRadius()
        addCustomShadow()
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        addSubview(mainStack)
        
        mainStack.addArrangedSubview(iconImage)
        mainStack.addArrangedSubview(textLabel)
        iconImage.heightAnchor.constraint(equalToConstant: textLabel.font.lineHeight*1.5).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: textLabel.font.lineHeight*1.5).isActive = true
        
        mainStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mainStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        mainStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        mainStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
        
    }
    
    
    static func getHeight() -> CGFloat {
        let cell = BuyDrugsCVCell()
        return cell.textLabel.font.lineHeight + cell.standartInset*2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

