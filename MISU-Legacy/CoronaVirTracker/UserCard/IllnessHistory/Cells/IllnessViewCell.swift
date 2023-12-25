//
//  IllnessViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 08.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class IllnessViewCell: UICollectionViewCell {
    let titleLabel: UILabel = .createTitle(text: "-", fontSize: 18, color: UIColor.black.withAlphaComponent(0.7) , alignment: .left)
    let confirmLabel: UILabel = .createTitle(text: "-", fontSize: 14, color: UIColor.black.withAlphaComponent(0.7) , alignment: .left)
    let dateLabel: UILabel = .createTitle(text: "-", fontSize: 14, color: UIColor.lightGray , alignment: .right)
    let stateLabel: UILabel = .createTitle(text: "-", fontSize: 14, color: UIColor.black.withAlphaComponent(0.7) , alignment: .right)
    
    var illnessModel: IllnessModel? {
        didSet {
            guard let illness = illnessModel else {return}
            titleLabel.text = illness.name ?? "-"
            confirmLabel.text = illness.confirmed?.localized ?? "-"
            dateLabel.text = illness.date?.getDate() ?? "-"
            stateLabel.text = illness.state?.localized ?? "-"
            if let st = illness.state { setUpState(st) }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetUp()
    }
    
    func setUpState(_ state: IllnessStateEnum) {
        stateLabel.textColor = state.color
        contentView.alpha = 1
        if state == .cured { contentView.alpha = 0.6 }
    }
    
    private func initSetUp() {
        contentView.backgroundColor = UIColor.white
        contentView.setCustomCornerRadius()
        contentView.addCustomShadow()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(confirmLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(stateLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        
        confirmLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        confirmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset).isActive = true
        confirmLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        confirmLabel.setContentHuggingPriority(.init(100), for: .horizontal)
        
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: standartInset).isActive = true
        dateLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        
        stateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        stateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        stateLabel.leadingAnchor.constraint(equalTo: confirmLabel.trailingAnchor, constant: standartInset).isActive = true
        stateLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
    
    static func getHeight(insets: Bool = true) -> CGFloat {
        let cell = IllnessViewCell()
        cell.titleLabel.sizeToFit()
        cell.confirmLabel.sizeToFit()
        return cell.titleLabel.frame.height + cell.confirmLabel.frame.height + cell.standartInset*3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

