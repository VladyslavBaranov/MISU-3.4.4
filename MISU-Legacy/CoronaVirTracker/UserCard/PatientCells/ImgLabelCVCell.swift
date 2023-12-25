//
//  ImgLabelCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 09.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class ImgLabelCVCell: UICollectionViewCell {
    let imageView: UIImageView = .makeImageView("analizesIcon")
    let titleLabel: UILabel = .createTitle(color: .lightGray, alignment: .center)
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpSubViews()
    }
    
    func setImageAnd(title: String, image: UIImage?) {
        imageView.image = image
        titleLabel.text = title
    }
    
    func setUpView() {
        backgroundColor = .white
        setCustomCornerRadius()
        addCustomShadow()
    }
    
    func setUpSubViews(cView: UIView? = nil) {
        let cView = cView ?? self
        
        cView.addSubview(imageView)
        cView.addSubview(titleLabel)
        
        imageView.topAnchor.constraint(equalTo: cView.topAnchor, constant: standart16Inset).isActive = true
        imageView.leadingAnchor.constraint(equalTo: cView.leadingAnchor, constant: standart16Inset).isActive = true
        imageView.customWidthAnchorConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageView.imageWidthToHeightMultiplier())
        imageView.customWidthAnchorConstraint?.isActive = true
        imageView.bottomAnchor.constraint(equalTo: cView.bottomAnchor, constant: -standart16Inset).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: cView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: standart16Inset/2).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cView.trailingAnchor, constant: -standart16Inset/2).isActive = true
        titleLabel.numberOfLines = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    static func getHeight(frame: CGRect) -> CGFloat {
        let cell = ImgLabelCVCell()
        let vv = UIView.createCustom()
        cell.setUpSubViews(cView: vv)
        vv.layoutIfNeeded()
        return cell.titleLabel.frame.height*5
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
