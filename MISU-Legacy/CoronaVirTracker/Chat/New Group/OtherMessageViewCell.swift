//
//  OtherMessageViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class OtherMessageViewCell: ChatMessageCustomViewCell {
    let timeLabel: UILabel = .createTitle(text: "00:00", fontSize: 12, color: .lightGray, alignment: .center, monospacedDigit: true)
    let statusImageView: UIImageView = .makeImageView("defaultMessageStatus", withRenderingMode: .alwaysTemplate, tintColor: .lightGray)
    
    var messageModel: MessageModel? {
        didSet {
            guard var newMessage = messageModel else {return}
            self.messageLabel.text = newMessage.text
            newMessage.sendDate = newMessage.dateTimeString?.toDate() ?? newMessage.sendDate
            self.timeLabel.text = newMessage.sendDate?.getTimeDateWitoutToday(kiev: true) ?? "-"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    override func updateInfo(_ msg: Message) {
        super.updateInfo(msg)
        
        messageLabel.text = msg.text
        timeLabel.text = msg.sendDate?.getTimeDateWitoutToday(kiev: true) ?? "-"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message?.text = ""
        timeLabel.text = ""
    }
    
    private func initSetUp() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(messageView)
        messageView.addSubview(messageLabel)
        contentView.addSubview(statusImageView)
        contentView.addSubview(timeLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        messageView.setRoundedParticly(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner], radius: 10)
        messageView.backgroundColor = .white
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        messageView.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -standartInset/2).isActive = true
        messageView.heightAnchor.constraint(greaterThanOrEqualToConstant: messageLabel.font.lineHeight+standartInset).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: standartInset/2).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -standartInset/2).isActive = true
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        statusImageView.centerYAnchor.constraint(equalTo: messageView.centerYAnchor).isActive = true
        statusImageView.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -standartInset/2).isActive = true
        statusImageView.heightAnchor.constraint(equalTo: timeLabel.heightAnchor).isActive = true
        statusImageView.widthAnchor.constraint(equalTo: statusImageView.heightAnchor).isActive = true
        
        timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -standartInset/2).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: messageView.centerYAnchor).isActive = true
        //timeLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        timeLabel.setContentHuggingPriority(UILayoutPriority(1001), for: .vertical)
        timeLabel.setContentHuggingPriority(UILayoutPriority(1001), for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getHeight(text: String, time: String?, frame: CGRect) -> CGFloat {
        let cell = OtherMessageViewCell(frame: frame)
        cell.messageLabel.text = text
        cell.timeLabel.text = time ?? "00:00"
        cell.layoutIfNeeded()
        return cell.messageView.frame.height
    }
}
