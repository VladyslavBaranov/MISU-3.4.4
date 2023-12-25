//
//  HospitalViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class HospitalViewCell: CustomUsersCollectionViewCell {
    let mainImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "hospitalIcon")
        img.clipsToBounds = true
        return img
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 18)
        lb.text = "Full Name of Hospital"
        return lb
    }()
    
    let adressLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.text = "Address"
        return tl
    }()
    
    var hospitalModel: HospitalModel? {
        didSet {
            nameLabel.text = hospitalModel?.fullName ?? "Name"
            adressLabel.text = hospitalModel?.location?.getFullLocationStr() ?? "Address"
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
        
        contentView.addSubview(mainImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(adressLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        mainImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        mainImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset/2).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        adressLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset/2).isActive = true
        adressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: standartInset/2).isActive = true
        adressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        mainImage.cornerRadius = HospitalViewCell.getHeight(insets: false)/2
    }
    
//    func isSelected(_ select: Bool) {
//        if select {
//            contentView.addBorder(radius: 3, color: UIColor.appDefault.green)
//        } else {
//            contentView.addBorder(radius: 0, color: .clear)
//        }
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private init() {
        super.init(frame: CGRect.zero)
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let cell = HospitalViewCell()
        let views = [cell.nameLabel, cell.adressLabel]
        
        
        var height: CGFloat = (cell.standartInset/2) * CGFloat(views.count-1)
        for v in views {
            v.sizeToFit()
            height += v.bounds.height
        }
        
        if insets {
            height += cell.standartInset*2
        }
        
        return height
    }
}
