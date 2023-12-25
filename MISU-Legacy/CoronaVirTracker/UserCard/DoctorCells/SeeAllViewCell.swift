//
//  SeeAllViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 24.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SeeAllViewCell: UICollectionViewCell {
    var titleLabel: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 16)
        tl.text = NSLocalizedString("See all", comment: "")
        tl.clipsToBounds = true
        return tl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    private func initSetUp() {
        contentView.backgroundColor = UIColor.white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        contentView.addSubview(titleLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
