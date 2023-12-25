//
//  NewsViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 30.04.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

class NewsViewCell: UICollectionViewCell {
    let coverImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "misuLogo")
        img.setRoundedParticly()
        return img
    }()
    
    let linkLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.textColor = UIColor.appDefault.red
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.text = "-"
        return lb
    }()
    
    let titleLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.black
        tl.numberOfLines = 2
        tl.font = UIFont.systemFont(ofSize: 18, weight: .bold)//systemFont(ofSize: 16)
        tl.text = "-"
        return tl
    }()
    
    let shortInfoLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.black
        tl.numberOfLines = 2
        tl.font = UIFont.systemFont(ofSize: 14)//systemFont(ofSize: 16)
        tl.text = "-"
        return tl
    }()
    
    let dateLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 12)
        tl.text = "-"
        return tl
    }()
    
    var newModel: NewModel? {
        didSet {
            /*let image = ImageCM.shared.get(byLink: newModel?.coverImageLink) { imageReq in
                DispatchQueue.main.async { self.coverImage.image = imageReq }
            }
            coverImage.image = image ?? UIImage(named: "misuLogo")*/
            if let url = newModel?.coverImageLink {
                coverImage.setImage(url: url)
            }
            
            guard let new = newModel else {return}
            titleLabel.text = new.title ?? "-"
            shortInfoLabel.text = new.info ?? "-"
            dateLabel.text = new.date?.toDate()?.getDateTime() ?? "-"
            linkLabel.text = new.link?.removeHTTPS() ?? "-"
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
        
        contentView.addSubview(coverImage)
        contentView.addSubview(linkLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(shortInfoLabel)
        contentView.addSubview(dateLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        coverImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coverImage.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        
        linkLabel.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: standartInset/2).isActive = true
        linkLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        linkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        linkLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        titleLabel.topAnchor.constraint(equalTo: linkLabel.bottomAnchor, constant: standartInset/2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        shortInfoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset/2).isActive = true
        shortInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        shortInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        shortInfoLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        dateLabel.topAnchor.constraint(equalTo: shortInfoLabel.bottomAnchor, constant: standartInset/2).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        dateLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset/2).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getHeight() -> CGFloat {
        let cell = NewsViewCell()
        cell.linkLabel.sizeToFit()
        cell.titleLabel.sizeToFit()
        cell.shortInfoLabel.sizeToFit()
        cell.dateLabel.sizeToFit()
        return (cell.linkLabel.frame.height + cell.titleLabel.frame.height + cell.shortInfoLabel.frame.height + cell.dateLabel.frame.height + cell.standartInset*5/2)*2.5
    }
}
