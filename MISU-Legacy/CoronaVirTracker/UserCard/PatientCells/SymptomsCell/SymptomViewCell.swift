//
//  SymptomViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SymptomViewCell: UICollectionViewCell {
    let titleLabel: UILabel = .createTitle(text: "-", fontSize: 16, color: UIColor.appDefault.red, alignment: .center)
    fileprivate let imageView: UIImageView = .makeImageView("first", contentMode: .scaleAspectFit)
    
    var image: UIImage? {
        didSet {
            guard let img = image else {
                imageView.isHidden = true
                contentView.animateChangeConstraints(deactivate: imageView.customTrailingAnchorConstraint, activate: titleLabel.customLeadingAnchorConstraint, duration: 0)
                return
            }
            imageView.image = img
            imageView.isHidden = false
            contentView.animateChangeConstraints(deactivate: titleLabel.customLeadingAnchorConstraint, activate: imageView.customTrailingAnchorConstraint, duration: 0)
        }
    }
    
    var title: String? {
        didSet {
            guard let tt = title else { return }
            titleLabel.text = NSLocalizedString(tt, comment: "")
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        titleLabel.customLeadingAnchorConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset)
        titleLabel.customLeadingAnchorConstraint?.isActive = true
        titleLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        titleLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        imageView.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.customTrailingAnchorConstraint = imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -standartInset/2)
        imageView.customTrailingAnchorConstraint?.isActive = false
        imageView.isHidden = true
        //titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let cell = SymptomViewCell()
        let views = [cell.titleLabel]
        
        
        var height: CGFloat = (cell.standartInset/2) * CGFloat(views.count-1)
        for v in views {
            v.sizeToFit()
            height += v.bounds.height
        }
        
        if insets {
            height += cell.standartInset*1.5
        }
        
        return height
    }
    
    func isSelected(_ select: Bool) {
        if select {
            contentView.backgroundColor = UIColor.appDefault.red
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = UIColor.appDefault.red
        }
    }
    
    static func getWidth(_ text: String, image: Bool = false) -> CGFloat {
        let cell = SymptomViewCell()
        cell.titleLabel.text = text
        cell.titleLabel.sizeToFit()
        var w = cell.titleLabel.frame.width + cell.standartInset*2
        if image {
            w += SymptomViewCell.getHeight(insets: false) + cell.standartInset/2
        }
        
        return w
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
