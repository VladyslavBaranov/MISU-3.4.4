//
//  UICustomVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 07.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class UICustomVC: UIViewController {
    var navigationStackView: UIStackView = .createCustom(axis: .vertical, spacing: 0, alignment: .center)
    var titleLabel: UILabel = .createTitle(text: "", fontSize: 17, weight: .medium , color: .black, alignment: .center)
    var subTitleLabel: UILabel = .createTitle(text: "", fontSize: 12, color: .lightGray, alignment: .center)
    
    var navigationItemTitle: String? {
        get {
            if navigationItem.titleView == navigationStackView {
                return titleLabel.text
            }
            return navigationItem.title
        }
        
        set {
            titleLabel.text = newValue
            if let _newValue = newValue, !_newValue.isEmpty {
                setUpNavigationStackView()
            }
        }
    }
    
    var navigationItemSubTitle: String? {
        get {
            if navigationItem.titleView == navigationStackView {
                return subTitleLabel.text
            }
            return nil
        }
        
        set {
            subTitleLabel.text = newValue
            if let _newValue = newValue, !_newValue.isEmpty {
                setUpNavigationStackView()
            }
        }
    }
}



extension UICustomVC {
    @objc func scrollByTabBarTab(animated: Bool) { }
    
    fileprivate func setUpNavigationStackView() {
        if navigationStackView.arrangedSubviews.firstIndex(of: titleLabel) == nil {
            navigationStackView.addArrangedSubview(titleLabel)
        }
        
        if navigationStackView.arrangedSubviews.firstIndex(of: subTitleLabel) == nil {
            navigationStackView.addArrangedSubview(subTitleLabel)
        }
        
        if navigationItem.titleView != navigationStackView {
            navigationItem.titleView = navigationStackView
        }
    }
}
