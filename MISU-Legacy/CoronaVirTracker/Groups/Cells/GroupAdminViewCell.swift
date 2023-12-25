//
//  GroupAdminViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 23.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class GroupAdminViewCell: UICollectionViewCell {
    let containerView: UIView = .createCustom(bgColor: .clear)
    let stackView: UIStackView = .createCustom([], axis: .vertical, distribution: .equalSpacing , spacing: 8)
    let userImageView: UIImageView = .makeImageView("patientDefImage", contentMode: .scaleAspectFill)
    let nameLabel: UILabel = .createTitle(text: "-", fontSize: 16, color: .black, alignment: .center)
    let statusLabel: UILabel = .createTitle(text: NSLocalizedString("Administrator", comment: "") , fontSize: 12, color: .lightGray, alignment: .center)
    
    var adminModel: UserModel? {
        didSet {
            nameLabel.text = adminModel?.profile?.name ?? adminModel?.doctor?.fullName ?? "-"
            if let imageUrl = adminModel?.profile?.imageURL ?? adminModel?.doctor?.imageURL {
                userImageView.setImage(url: imageUrl, defaultImageName: "patientDefImage")
            } else {
                userImageView.image = UIImage(named: "userImageView")
            }
        }
    }
    
    var collFrame: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collFrame = frame
        initSetUp()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(userImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(statusLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        contentView.backgroundColor = .clear
        containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(userImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(statusLabel)
        
        contentView.layoutIfNeeded()
        let imgSize = collFrame.width/4
        //let imgSize = standartInset*4
        userImageView.heightAnchor.constraint(equalToConstant: imgSize).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: imgSize).isActive = true
        userImageView.cornerRadius = imgSize/2
        
        nameLabel.sizeToFit()
        statusLabel.sizeToFit()
        
        stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standartInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: standartInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -standartInset).isActive = true
        let stackHeight = imgSize + nameLabel.frame.height + statusLabel.frame.height + stackView.spacing*CGFloat(stackView.arrangedSubviews.count)
        stackView.heightAnchor.constraint(equalToConstant: stackHeight).isActive = true
        stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -standartInset).isActive = true
        stackView.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        stackView.setContentHuggingPriority(UILayoutPriority(1001), for: .vertical)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getHeight(frame: CGRect) -> CGFloat {
        //let frm  = CGRect(origin: .zero, size: CGSize(width: frame.size.width, height: 0))
        let cell = GroupAdminViewCell(frame: frame)
        cell.layoutIfNeeded()
        return cell.containerView.frame.height
    }
}
