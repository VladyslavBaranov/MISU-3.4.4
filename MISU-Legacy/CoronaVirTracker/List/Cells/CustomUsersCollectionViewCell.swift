//
//  CustomUsersCollectionViewCell.swift
//  CoronaVirTracker
//
//  Created by WH ak on 05.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class CustomUsersCollectionViewCell: UICollectionViewCell {
    func isSelected(_ select: Bool) {
        if select {
            contentView.addBorder(radius: 3, color: UIColor.appDefault.green)
        } else {
            contentView.addBorder(radius: 0, color: .clear)
        }
    }
}
