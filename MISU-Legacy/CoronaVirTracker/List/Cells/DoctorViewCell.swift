//
//  DoctorViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 09.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class DoctorViewCell: CustomUsersCollectionViewCell {
    let mainImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "notApprovedDocStatus")
        img.clipsToBounds = true
        return img
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 18)
        lb.text = "-"
        return lb
    }()
    
    let postLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.text = "-"
        return tl
    }()
    
    let hospitalLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.text = "-"
        return tl
    }()
    
    var doctorModel: UserModel? {
        didSet {
            //guard let doc = doctorModel?.doctor else { return }
            nameLabel.text = doctorModel?.doctor?.fullName ?? "-"
            postLabel.text = doctorModel?.doctor?.docPost?.name ?? "-"
            hospitalLabel.text = doctorModel?.doctor?.hospitalModel?.fullName ?? "-"
            
            let image = ImageCM.shared.get(byLink: doctorModel?.doctor?.imageURL) { imageReq in
                DispatchQueue.main.async { self.mainImage.image = imageReq }
            }
            self.mainImage.image = image ?? UIImage(named: "notApprovedDocStatus")
            
//            if doctorModel?.id == 22 || doctorModel?.doctor?.id == 10 {
//                contentView.addBorder(radius: 2, color: UIColor.appDefault.red)
//                contentView.backgroundColor = UIColor(hexString: "#FFCFD8")
//            } else {
//                contentView.addBorder(radius: 0, color: .clear)
//                contentView.backgroundColor = .white
//            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = .white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        contentView.addSubview(mainImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(postLabel)
        contentView.addSubview(hospitalLabel)
        
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
        
        postLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset/2).isActive = true
        postLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: standartInset/2).isActive = true
        postLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        hospitalLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset/2).isActive = true
        hospitalLabel.topAnchor.constraint(equalTo: postLabel.bottomAnchor, constant: standartInset/2).isActive = true
        hospitalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        mainImage.cornerRadius = DoctorViewCell.getHeight(insets: false)/2
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
        let cell = DoctorViewCell()
        let views = [cell.nameLabel, cell.postLabel, cell.hospitalLabel]
        
        
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
