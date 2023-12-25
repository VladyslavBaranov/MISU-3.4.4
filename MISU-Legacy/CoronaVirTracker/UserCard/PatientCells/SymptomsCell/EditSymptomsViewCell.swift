//
//  EditSymptomsViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 21.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class EditSymptomsViewCell: UICollectionViewCell {
    var titleLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 16)
        tl.text = NSLocalizedString("Edit", comment: "")
        tl.clipsToBounds = true
        return tl
    }()
    
    var editImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.image = UIImage(named: "editImg")
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = UIColor.white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        contentView.addSubview(editImageView)
        contentView.addSubview(titleLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        editImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        editImageView.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        editImageView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        editImageView.widthAnchor.constraint(equalTo: editImageView.heightAnchor).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: editImageView.trailingAnchor, constant: standartInset/2).isActive = true
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1001), for: .vertical)
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
    
    static func getWidth() -> CGFloat {
        let cell = EditSymptomsViewCell()
        cell.titleLabel.sizeToFit()
        
        return cell.titleLabel.frame.width + cell.titleLabel.frame.height + cell.standartInset*2.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
