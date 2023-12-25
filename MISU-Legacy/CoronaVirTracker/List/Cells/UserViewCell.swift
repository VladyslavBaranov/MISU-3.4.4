//
//  UserViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class UserViewCell: CustomUsersCollectionViewCell {
    let mainImage: UIImageView = .makeImageView("patientDefImage", contentMode: .scaleAspectFill )
    let nameLabel: UILabel = .createTitle(text: "Full Name", fontSize: 18, alignment: .left)
    let statusImage: UIImageView = .makeImageView(HealthStatusEnum.well.imageName, contentMode: .scaleAspectFit)
    let temperatureLabel: UILabel = .createTitle(text: "36.6˚", fontSize: 14, color: .lightGray, alignment: .left)
    var sessionTask: URLSessionTask? = nil
    
    var userModel: UserModel? {
        didSet {
            sessionTask?.cancel()
            nameLabel.text = userModel?.profile?.name ?? userModel?.doctor?.fullName ?? "-"
            
            temperatureLabel.text = "\(userModel?.profile?.temperature ?? 36.6)˚"
            statusImage.image = userModel?.profile?.status?.new.getSmileImage() ?? HealthStatusEnum.well.getSmileImage()
            
            if let imageUrl = userModel?.profile?.imageURL ?? userModel?.doctor?.imageURL {
                mainImage.setImage(url: imageUrl, defaultImageName: "patientDefImage")
            }
            
            guard let uId = userModel?.profile?.id else { return }
            sessionTask = ListDHManager.shared.getProfile(id: uId) { [weak self] (patientList, error) in
                if let newPatient = patientList?.first {
                    DispatchQueue.main.async {
                        self?.temperatureLabel.text = "\(newPatient.profile?.temperature ?? 36.6)˚"
                        self?.statusImage.image = newPatient.profile?.status?.new.getSmileImage() ?? HealthStatusEnum.well.getSmileImage()
                        if let imageUrl = newPatient.profile?.imageURL ?? newPatient.doctor?.imageURL {
                            self?.mainImage.setImage(url: imageUrl, defaultImageName: "patientDefImage")
                        }
                    }
                }
                if let er = error { print(er) }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //userModel = .init(id: -1)
        mainImage.image = UIImage(named: "patientDefImage")
    }
    
    private func initSetUp() {
        contentView.backgroundColor = UIColor.white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        contentView.addSubview(mainImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusImage)
        contentView.addSubview(temperatureLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        mainImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        mainImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        mainImage.widthAnchor.constraint(equalTo: mainImage.heightAnchor).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset/2).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: statusImage.leadingAnchor, constant: -standartInset/2).isActive = true
        
        temperatureLabel.leadingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: standartInset/2).isActive = true
        temperatureLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: standartInset/2).isActive = true
        //temperatureLabel.trailingAnchor.constraint(equalTo: statusImage.leadingAnchor, constant: -standartInset).isActive = true
        temperatureLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1001), for: .vertical)
        
        //statusImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        statusImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        statusImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        //statusImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        statusImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4).isActive = true
        statusImage.widthAnchor.constraint(equalTo: statusImage.heightAnchor).isActive = true
        
        
        mainImage.cornerRadius = UserViewCell.getHeight(insets: false)/2
    }
    
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
        let cell = UserViewCell()
        let views = [cell.nameLabel, cell.temperatureLabel]
        
        
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
