//
//  TitleCollectionReusableView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class TitleCollectionReusableView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let tt = UILabel()
        tt.translatesAutoresizingMaskIntoConstraints = false
        tt.textColor = UIColor.gray
        tt.font = UIFont.systemFont(ofSize: 14)
        tt.text = "Title"
        return tt
    }()
    
    let hideShowButton: UIButton = .createCustom(title: NSLocalizedString("Hide", comment: ""), color: .clear, fontSize: 14, textColor: .lightGray, shadow: false, customContentEdgeInsets: false)
    
    var hideShowAction: (()->Bool)? {
        didSet {
            hideShowButton.isHidden = false
        }
    }
    
    var isHiddenContext: Bool? {
        didSet {
            hideContext(isHiddenContext ?? false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    
    init(text: String = "Title") {
        super.init(frame: .zero)
        titleLabel.text = text
        
        initSetUp()
    }
    
    func initSetUp() {
        self.addSubview(titleLabel)
        self.addSubview(hideShowButton)
        
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        hideShowButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
        hideShowButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let txt = NSMutableAttributedString(string: NSLocalizedString("Hide", comment: ""), attributes: [.underlineStyle:NSUnderlineStyle.single.rawValue, .underlineColor:UIColor.lightGray])
        hideShowButton.setAttributedTitle(txt, for: .normal)
        hideShowButton.tintColor = UIColor.lightGray
        hideShowButton.isHidden = true
        hideShowButton.addTarget(self, action: #selector(hideShowButtonAction), for: .touchUpInside)
    }
    
    @objc private func hideShowButtonAction() {
        hideContext(hideShowAction?() ?? false)
    }
    
    func hideContext(_ hide: Bool) {
        if hide {
            let txt = NSMutableAttributedString(string: NSLocalizedString("Show", comment: ""), attributes: [.underlineStyle:NSUnderlineStyle.single.rawValue, .underlineColor:UIColor.lightGray])
            hideShowButton.setAttributedTitle(txt, for: .normal)
            return
        }
        let txt = NSMutableAttributedString(string: NSLocalizedString("Hide", comment: ""), attributes: [.underlineStyle:NSUnderlineStyle.single.rawValue, .underlineColor:UIColor.lightGray])
        hideShowButton.setAttributedTitle(txt, for: .normal)
        return
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let view = TitleCollectionReusableView()
        let views = [view.titleLabel]
        
        var height: CGFloat = (view.standartInset/2) * CGFloat(views.count-1)
        for v in views {
            v.sizeToFit()
            height += v.bounds.height
        }
        
        if insets {
            height += view.standartInset
        }
        
        return height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
