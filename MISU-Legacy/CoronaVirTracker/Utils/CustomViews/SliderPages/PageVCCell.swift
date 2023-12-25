//
//  PageVCCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 13.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class PageOneViewVCCell: UICollectionViewCell {
    var mainView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp(mainView: mainView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mainView?.removeFromSuperview()
        mainView = nil
    }
    
    func setUp(mainView mv: UIView?) {
        mainView?.removeFromSuperview()
        mainView = mv
        guard let mv = mainView else { return }
        
        addSubview(mv)
        
        mv.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        mv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        mv.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        mv.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        mv.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp(mainView: mainView)
    }
}

class PageVCCell: UICollectionViewCell {
    let imageView: UIImageView = .makeImageView()
    let textLabel: UILabel = .createTitle(text: NSLocalizedString("Text", comment: ""),
                                          fontSize: 18, color: .white, alignment: .center)
    var additionalView: UIView? = nil
    
    var data: SliderDataStruct? {
        didSet {
            imageView.image = data?.image ?? UIImage(named: "defaultImage")
            
            textLabel.text = data?.text ?? "-"
            textLabel.customBottomAnchorConstraint?.isActive = false
            //textLabel.textColor = data?.textColor
            
            additionalView?.removeFromSuperview()
            additionalView = data?.additional
            
            if let add = additionalView {
                addSubview(add)
                add.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: standart24Inset).isActive = true
                add.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                add.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                add.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            } else {
                textLabel.customBottomAnchorConstraint = textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
                textLabel.customBottomAnchorConstraint?.isActive = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    func initSetUp() {
        addSubview(imageView)
        addSubview(textLabel)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -standart24Inset).isActive = true
        
        textLabel.numberOfLines = 42
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        textLabel.customBottomAnchorConstraint = textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        textLabel.customBottomAnchorConstraint?.isActive = true
        
        textLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

