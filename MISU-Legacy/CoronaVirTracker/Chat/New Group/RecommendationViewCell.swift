//
//  RecommendationViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 18.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class RecommendationViewCell: ChatMessageCustomViewCell {    
    let stackView: UIStackView = .createCustom([], axis: .horizontal, distribution: .fill,spacing: 16)
    let iconImageView: UIImageView = .makeImageView("misuLogo")
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Recommendations", comment: ""), fontSize: 14, color: UIColor.lightGray, alignment: .left)
    let timeLabel: UILabel = .createTitle(text: "-:-", fontSize: 12, color: UIColor.lightGray, alignment: .center, monospacedDigit: true)
    
    let imageView: UIImageView = .makeImageView(contentMode: .scaleAspectFill)
    /*let orderButton: UIButton = .createCustom(title: NSLocalizedString("Order", comment: ""),
                                              color: UIColor.appDefault.red, fontSize: 16,
                                              disabledTextColor: UIColor.appDefault.red)*/
    
    var messageModel: MessageModel? {
        didSet {
            //updateOrderButton()
            guard var newMessage = messageModel else {return}
            self.messageLabel.text = newMessage.text
            newMessage.sendDate = newMessage.dateTimeString?.toDate() ?? newMessage.sendDate
            self.timeLabel.text = newMessage.sendDate?.getTimeDateWitoutToday(kiev: true) ?? "-"
            guard let imgLnk = newMessage.imageLink else {
                isShowImageView(false)
                return
            }
            isShowImageView(true)
            imageView.setImage(url: imgLnk)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    override func updateInfo(_ msg: Message) {
        super.updateInfo(msg)
        
        //updateOrderButton()
        self.messageLabel.text = msg.text
        self.timeLabel.text = msg.sendDate?.getTimeDateWitoutToday(kiev: true) ?? "-"
        guard let imgLnk = msg.imageLink else {
            isShowImageView(false)
            return
        }
        isShowImageView(true)
        imageView.setImage(url: imgLnk)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message?.text = ""
        timeLabel.text = ""
        //updateOrderButton()
        isShowImageView(false)
        imageView.image = UIImage(named: "defaultImage")
    }
    
    /*func updateOrderButton() {
        if messageModel?.isOrdered == false {
            orderButton.isEnabled = true
            orderButton.backgroundColor = UIColor.appDefault.red
            orderButton.addCustomShadow()
        } else {
            orderButton.isEnabled = false
            orderButton.backgroundColor = .clear
            orderButton.removeShadow()
        }
    }*/
    
    /*@objc func orderButtonAction() {
        guard let mId = messageModel?.id else { return }
        prepareViewsBeforReqest(viewsToBlock: [], activityButton: orderButton)
        OrdersManager.shared.resendOrder(messageId: mId) { [self] success, errorOp in
            enableViewsAfterReqest()
            if success {
                DispatchQueue.main.async {
                    messageModel?.isOrdered = true
                }
            }
            
            if let error = errorOp {
                ModalMessagesController.shared.show(message: error.message, type: .error)
            }
        }
    }*/
    
    private func initSetUp() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(messageView)
        messageView.addSubview(messageLabel)
        messageView.addSubview(stackView)
        messageView.addSubview(imageView)
        //messageView.addSubview(orderButton)
        
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
        
        imageView.customTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: standartInset)
        imageView.customTopAnchorConstraint?.isActive = true
        imageView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        imageView.customHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: standartInset*3)
        imageView.customHeightAnchorConstraint?.isActive = true
        imageView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        //imageView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -standartInset).isActive = true
        imageView.setCustomCornerRadius()
        isShowImageView(false)
        imageView.addOpenFullImageTapAction()
        
        messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: standartInset).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -standartInset).isActive = true
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        /*orderButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: standartInset).isActive = true
        orderButton.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: standartInset).isActive = true
        orderButton.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -standartInset).isActive = true
        orderButton.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -standartInset).isActive = true
        orderButton.addTarget(self, action: #selector(orderButtonAction), for: .touchUpInside)
        orderButton.setTitle(NSLocalizedString("Order", comment: ""), for: .normal)
        orderButton.setTitle(NSLocalizedString("Ordered", comment: ""), for: .disabled)
        orderButton.setTitleColor(.white, for: .normal)
        orderButton.setTitleColor(UIColor.appDefault.red, for: .disabled)*/
    }
    
    func isShowImageView(_ isShow: Bool) {
        if isShow {
            layoutIfNeeded()
            imageView.animateConstraint(imageView.customTopAnchorConstraint, constant: standartInset, duration: 0)
            //imageView.animateConstraint(imageView.customHeightAnchorConstraint, constant: standartInset*3, duration: 0)
            imageView.animateConstraint(imageView.customHeightAnchorConstraint, constant: imageView.frame.width, duration: 0)
            return
        }
        imageView.animateConstraint(imageView.customTopAnchorConstraint, constant: 0, duration: 0)
        imageView.animateConstraint(imageView.customHeightAnchorConstraint, constant: 0, duration: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getHeight(text: String, frame: CGRect, isImage: Bool) -> CGFloat {
        let cell = RecommendationViewCell(frame: frame)
        cell.messageLabel.text = text
        cell.isShowImageView(isImage)
        cell.layoutIfNeeded()
        return cell.messageView.frame.height
    }
}
