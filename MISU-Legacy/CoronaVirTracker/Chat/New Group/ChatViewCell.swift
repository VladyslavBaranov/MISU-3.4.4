//
//  ChatViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/7/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ChatViewCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? { return getAddress() }
    
    let profileImageView: UIImageView = .makeImageView("patientDefImage", contentMode: .scaleAspectFill)
    let nameLabel: UILabel = .createTitle(text: "Full Name", fontSize: 16)
    let messageLabel: UILabel = .createTitle(text: "Message", color: .lightGray)
    let countOfNewLabel: UILabel = .createTitle(text: " ", fontSize: 16, color: .lightGray, alignment: .center)
    let redView: UIView = .createCustom(bgColor: UIColor.appDefault.redNew)
    let timeLabel: UILabel = .createTitle(text: "-", color: .lightGray, alignment: .center)
    
    let chatManager = ChatsSinglManager.shared
    var session: URLSessionTask?
    var otherSession: URLSessionTask?
    
    var chat: Chat? {
        didSet {
            guard let ch = chat else { return }
            updateInfo(ch)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    func setChat(_ ch: Chat?) {
        session?.cancel()
        otherSession?.cancel()
        enableViewsAfterReqest()
        guard let ch = ch, let chId = ch.id else { return }
        
        if let cch = chatManager.getChatBy(id: chId) {
            chat = cch
            //updateInfo(ch)
        } else {
            chat = ch
            chatManager.setChat(ch)
        }
        
        if chat?.messages.isEmpty == true {
            prepareViewsBeforReqest(viewsToBlock: [], activityView: self)
        }
        session = ChatManager.shared.getChatBy(id: chId) { newChat, error in
            self.enableViewsAfterReqest()
            //print("### getChatBy \(chId) \(String(describing: newChat))")
            //print("### getChatBy error \(String(describing: error))")
            
            if let ch = newChat?.first {
                self.chat?.update(ch)
                DispatchQueue.main.async {
                    self.updateInfo(self.chat ?? ch)
                }
                
                self.prepareViewsBeforReqest(viewsToBlock: [], activityView: self.profileImageView)
                let id = self.chat?.id
                self.otherSession = self.chat?.updateParticipants({
                    self.enableViewsAfterReqest()
                    DispatchQueue.main.async {
                        //print("### update info \(id) \(self.chat?.id) \(self.chat?.participants.count)")
                        if self.chat?.id == id {
                            self.updateInfo(self.chat ?? ch)
                        }
                    }
                })
            }
        }
    }
    
    func updateInfo(_ ch: Chat) {
        self.messageLabel.text = ch.messages.first?.text ?? "-"
        let other = ch.participants.first(where: {$0.id != UCardSingleManager.shared.user.id})
        self.nameLabel.text = other?.profile?.name ?? other?.doctor?.fullName ?? "-"
        
        self.timeLabel.text = ch.last_message?.toDate(ch: true)?.getTimeDateWitoutToday(short: true, kiev: true) ?? "-"
        
        if let imgUrl = other?.profile?.imageURL ?? other?.doctor?.imageURL {
            profileImageView.setImage(url: imgUrl, defaultImageName: "patientDefImage")
        } else {
            self.profileImageView.image = UIImage(named: "patientDefImage")
        }
        
        if ch.unread > 0 {
            self.countOfNewLabel.text = "\(ch.unread)"
        } else {
            self.countOfNewLabel.text = ""
        }
        setUpCountOfNewLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        session?.cancel()
        otherSession?.cancel()
        
        profileImageView.image = UIImage(named: "patientDefImage")
        nameLabel.text = "-"
        messageLabel.text = "-"
        timeLabel.text = "-"
        countOfNewLabel.text = "-"
        enableViewsAfterReqest()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = .white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(redView)
        contentView.addSubview(countOfNewLabel)
        contentView.addSubview(timeLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        profileImageView.cornerRadius = (nameLabel.font.lineHeight + messageLabel.font.lineHeight + standartInset/2)/2
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: standartInset).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: countOfNewLabel.leadingAnchor, constant: -standartInset/2).isActive = true
        //nameLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: standartInset).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -standartInset/2).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        messageLabel.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)
        
        timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        timeLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .horizontal)
        
        
        countOfNewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        countOfNewLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        //countOfNewLabel.widthAnchor.constraint(equalTo: countOfNewLabel.heightAnchor).isActive = true
        countOfNewLabel.setContentHuggingPriority(UILayoutPriority(1001), for: .horizontal)
        countOfNewLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .horizontal)
        
        redView.centerYAnchor.constraint(equalTo: countOfNewLabel.centerYAnchor).isActive = true
        redView.centerXAnchor.constraint(equalTo: countOfNewLabel.centerXAnchor).isActive = true
        redView.heightAnchor.constraint(equalTo: countOfNewLabel.heightAnchor, multiplier: 1.1).isActive = true
        redView.widthAnchor.constraint(equalTo: countOfNewLabel.heightAnchor, multiplier: 1.1).isActive = true
        
        redView.cornerRadius = (countOfNewLabel.font.lineHeight*1.1)/2
        
        contentView.bringSubviewToFront(countOfNewLabel)
        
        setUpCountOfNewLabel()
    }
    
    func setUpCountOfNewLabel() {
        //redView.cornerRadius = redView.frame.height/2
        if countOfNewLabel.text?.isEmpty == false {
            countOfNewLabel.textColor = .white
            redView.animateShow(duration: 0.1)
            //countOfNewLabel.backgroundColor = UIColor.appDefault.red
            //countOfNewLabel.cornerRadius = countOfNewLabel.frame.height
        } else {
            countOfNewLabel.textColor = .lightGray
            redView.animateFade(duration: 0.1)
            //countOfNewLabel.backgroundColor = .clear
            //countOfNewLabel.cornerRadius = countOfNewLabel.frame.height
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //redView.cornerRadius = redView.frame.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let cell = ChatViewCell()
        let views = [cell.nameLabel, cell.messageLabel]
        
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
}

