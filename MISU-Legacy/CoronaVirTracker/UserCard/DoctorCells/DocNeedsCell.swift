//
//  DocNeedsCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 23.04.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

class DocNeedsCell: UICollectionViewCell {
    let leftTitle: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.black
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.numberOfLines = 2
        tl.text = "Title"
        tl.sizeToFit()
        return tl
    }()
    
    let rightTitle: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.text = "-"
        tl.sizeToFit()
        return tl
    }()
    
    var needItem: NeedsModel? {
        didSet {
            guard let nd = needItem else {return}
            
            leftTitle.text = nd.name
            rightTitle.text = "-"
            if let count = nd.count {
                rightTitle.text = "\(count)"
            }
            
            if nd.done ?? false {
                leftTitle.textColor = UIColor.appDefault.green
            } else {
                leftTitle.textColor = UIColor.appDefault.red
            }
        }
    }
    
    var sugarValue: Float? {
        didSet {
            leftTitle.text = NSLocalizedString("Blood sugar (mmol/L)", comment: "") + ":"
            rightTitle.text = "-"
            guard let value = sugarValue else {return}
            rightTitle.text = String(value)
        }
    }
    
    var insulinValue: Float? {
        didSet {
            leftTitle.text = NSLocalizedString("Insulin (ml)", comment: "") + ":"
            rightTitle.text = "-"
            guard let value = insulinValue else {return}
            rightTitle.text = String(value)
        }
    }
    
    var paramValue: HealthParameterModel? {
        didSet {
            leftTitle.text = "-"
            if let value = paramValue?.value {
                leftTitle.text = "\(value)"
            }
            rightTitle.text = paramValue?.date?.toDate()?.getTimeDateWitoutToday() ?? "-"
            print(paramValue?.date?.toDate() as Any)
            print(paramValue?.date?.toDate()?.getTimeDateWitoutToday() as Any)
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
        
        contentView.addSubview(leftTitle)
        contentView.addSubview(rightTitle)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        leftTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        
        leftTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        leftTitle.trailingAnchor.constraint(equalTo: rightTitle.leadingAnchor, constant: -16).isActive = true
        
        rightTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rightTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        rightTitle.setContentCompressionResistancePriority(.init(1001), for: .horizontal)
        rightTitle.setContentHuggingPriority(.init(1001), for: .horizontal)
    }
    
    func weNeedView() {
        leftTitle.textColor = UIColor.appDefault.red
    }
    
    func weHaveView() {
        leftTitle.textColor = UIColor.appDefault.green
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let cell = DocNeedsCell()
        let views = [cell.rightTitle]
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

