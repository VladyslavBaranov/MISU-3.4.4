//
//  CustomCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 07.04.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class BestCVCell: UICollectionViewCell {
    let mainStack: UIStackView = .createCustom(axis: .vertical, alignment: .leading)
    let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 18, weight: .bold, color: .white, numberOfLines: 3)
    let subTitleLabel: UILabel = .createTitle(text: "Title", fontSize: 16, color: .white, numberOfLines: 3)
    let bgImageView: UIImageView = .createCustom(contentMode: .scaleAspectFill)
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        contentView.addSubview(bgImageView)
        contentView.cornerRadius = 21
        bgImageView.fixedEdgesConstraints(on: contentView, inset: .zero)
        
        contentView.addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: contentView, inset: .init(top: standart24Inset, left: standart24Inset,
                                                                      bottom: standart24Inset, right: standart24Inset))
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(subTitleLabel)
        
        contentView.sendSubviewToBack(bgImageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}

class CustomCVCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc func getSize(cv: UICollectionView) -> CGSize {
        return .init(width: standart24Inset, height: standart24Inset)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
