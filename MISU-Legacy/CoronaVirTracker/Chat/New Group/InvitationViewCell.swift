//
//  InvitationViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 21.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class InvitationViewCell: ChatMessageCustomViewCell {
    let stackView: UIStackView = .createCustom([], axis: .horizontal, distribution: .fill,spacing: 16)
    let iconImageView: UIImageView = .makeImageView("groupIcon")
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Family access", comment: ""), fontSize: 14, color: UIColor.lightGray, alignment: .left)
    let timeLabel: UILabel = .createTitle(text: "-:-", fontSize: 12, color: UIColor.lightGray, alignment: .center, monospacedDigit: true)
    
    let accDecButtonsSV: UIStackView = .createCustom([], axis: .horizontal, distribution: .fillEqually, spacing: 16)
    let acceptButton: UIButton = .createCustom(title: NSLocalizedString("Accept", comment: ""),
                                               color: UIColor.appDefault.red, fontSize: 14, textColor: .white,
                                               shadow: true, customContentEdgeInsets: true, setCustomCornerRadius: true)
    let declineButton: UIButton = .createCustom(title: NSLocalizedString("Decline", comment: ""),
                                               color: .white, fontSize: 14, textColor: UIColor.appDefault.red,
                                               shadow: false, customContentEdgeInsets: true, setCustomCornerRadius: true)
    let statusLabel: UILabel = .createTitle(text: GroupInviteStatus.pending.localized, fontSize: 16, color: UIColor.appDefault.red, alignment: .center)
    
    var messageModel: Message? {
        didSet {
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    override func updateInfo(_ msg: Message) {
        super.updateInfo(msg)
        messageModel = msg
        self.messageLabel.text = msg.text
        self.timeLabel.text = msg.sendDate?.getTimeDateWitoutToday(kiev: true) ?? "-"
        setUpInvitation()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message?.text = ""
        timeLabel.text = ""
        setUpInvitation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - Actions
extension InvitationViewCell {
    @objc func acceptButtonAction() {
        replyToRequest(true)
        prepareViewsBeforReqest(viewsToBlock: [declineButton], activityButton: acceptButton)
    }
    
    @objc func declineButtonAction() {
        replyToRequest(false)
        prepareViewsBeforReqest(viewsToBlock: [acceptButton], activityButton: declineButton)
    }
    
    func replyToRequest(_ accept: Bool) {
        guard let invitation = messageModel?.invitation else {
            enableViewsAfterReqest()
            return
        }
        
        GroupsManager.shared.replyToInvite(invitation, accept: accept) { [self] (inviteOp, errorOp) in
            enableViewsAfterReqest()
            if let invite = inviteOp {
                print("### invitation reply Success: \(String(describing: invite.status))")
                DispatchQueue.main.async {
                    messageModel?.invitation = invite
                    //setUpInvitation()
                }
            }
            
            if let error = errorOp {
                print("### invitation reply ERROR: \(error)")
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }
}
 


// MARK: - SetUp
extension InvitationViewCell {
    func setUpInvitation() {
        //print("###$ \(messageModel)")
        //print("###$$ \(messageModel?.invitation)")
        guard let invitation = messageModel?.invitation else {
            accDecButtonsSV.animateFade(duration: 0.1)
            statusLabel.animateShow(duration: 0.1)
            return
        }
        print("### invitation \n\(invitation)")
        statusLabel.text = invitation.statusEnum.localized
        if messageModel?.isMyMessage == true || invitation.status != nil {
            accDecButtonsSV.animateFade(duration: 0.1)
            statusLabel.animateShow(duration: 0.1)
        } else {
            accDecButtonsSV.animateShow(duration: 0.1)
            statusLabel.animateFade(duration: 0.1)
        }
    }
    
    private func initSetUp() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(messageView)
        messageView.addSubview(messageLabel)
        messageView.addSubview(stackView)
        messageView.addSubview(accDecButtonsSV)
        messageView.addSubview(statusLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        messageView.cornerRadius = 10
        messageView.backgroundColor = .white
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset*2).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset*2).isActive = true
        messageView.heightAnchor.constraint(greaterThanOrEqualToConstant: messageLabel.font.lineHeight+standartInset).isActive = true
        
        stackView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: standartInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight).isActive = true
        iconImageView.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.init(100), for: .vertical)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        timeLabel.translatesAutoresizingMaskIntoConstraints = true
        
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        timeLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(timeLabel)
        
        messageLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: standartInset).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        accDecButtonsSV.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: standartInset).isActive = true
        accDecButtonsSV.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        acceptButton.sizeToFit()
        accDecButtonsSV.heightAnchor.constraint(equalToConstant: acceptButton.bounds.height).isActive = true
        accDecButtonsSV.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        accDecButtonsSV.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -standartInset).isActive = true
        accDecButtonsSV.addArrangedSubview(acceptButton)
        accDecButtonsSV.addArrangedSubview(declineButton)
        declineButton.addBorder(radius: 2, color: UIColor.appDefault.red)
        declineButton.addTarget(self, action: #selector(declineButtonAction), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonAction), for: .touchUpInside)
        
        statusLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: standartInset).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        statusLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -standartInset).isActive = true
        
        accDecButtonsSV.animateFade(duration: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    static func getHeight(text: String, frame: CGRect) -> CGFloat {
        let cell = InvitationViewCell(frame: frame)
        cell.messageLabel.text = text
        cell.layoutIfNeeded()
        return cell.messageView.frame.height
    }
}
