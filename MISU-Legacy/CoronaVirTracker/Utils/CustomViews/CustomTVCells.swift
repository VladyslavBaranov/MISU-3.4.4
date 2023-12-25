//
//  Value1TVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.04.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class Value1TVCell: UITableViewCell {
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelected(false, animated: true) : pass
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SubtitleTVCell: UITableViewCell {
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelected(false, animated: true) : pass
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomTVCell: UITableViewCell {
    let mainStack: UIStackView = .createCustom(axis: .horizontal)
    let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 16)
    let iconImage: UIImageView = .makeImageView()
    
    var mainStackEdgeInset: UIEdgeInsets {
        .init(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelected(false, animated: true) : pass
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    func setUp() {
        contentView.addSubview(mainStack)
        mainStack.customConstraints(alignment: .none, on: contentView, inset: mainStackEdgeInset)
        mainStack.addArrangedSubview(iconImage)
        mainStack.addArrangedSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}
