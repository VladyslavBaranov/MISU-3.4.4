//
//  PresentUIViewController.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class PresentUIViewController: UIViewController {
    let cancelButton: UIButton = .createCustom(title: NSLocalizedString("Cancel", comment: ""),
                                               color: .clear, textColor: UIColor.appDefault.redNew, shadow: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    @objc func cancelButtonAction() {
        dismiss(animated: true)
    }
    
    @objc dynamic func setUp() {
        view.backgroundColor = .white
        view.addSubview(cancelButton)
        
        let topConst = view.standart24Inset-cancelButton.contentEdgeInsets.top
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topConst).isActive = true
        let trailingConst = -(view.standart24Inset-cancelButton.contentEdgeInsets.right)
        cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: trailingConst).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
    }
}

class ScrollPresentVC: PresentUIViewController {
    let bgImage: UIImageView = .makeImageView("sleepBG1", contentMode: .scaleAspectFill)
    let scrollView: UIScrollView = .create()
    let mainStack: UIStackView = .createCustom(axis: .vertical, distribution: .fill)
    
    let titleLabel: UILabel = .createTitle(fontSize: 22, weight: .bold, color: .white, alignment: .center, numberOfLines: 5)
    let subTitleLabel: UILabel = .createTitle(color: .lightGray, alignment: .center, numberOfLines: 5)
    
    var scrollViewEdgesConstraints: UIEdgeInsets = .zero {
        didSet {
            scrollView.removeFromSuperview()
            view.addSubview(scrollView)
            scrollView.fixedEdgesConstraints(on: view, inset: scrollViewEdgesConstraints)
        }
    }
    
    var bgImageEdgesConstraints: UIEdgeInsets = .zero {
        didSet {
            bgImage.removeFromSuperview()
            scrollView.addSubview(bgImage)
            bgImage.fixedEdgesConstraints(on: scrollView, inset: bgImageEdgesConstraints)
            if let trc = bgImage.customTrailingAnchorConstraint {
                bgImage.removeConstraint(trc)
            }
            bgImage.customTrailingAnchorConstraint = bgImage.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor)
            bgImage.customTrailingAnchorConstraint?.isActive = true
        }
    }
    
    var mainStackEdgesConstraints: UIEdgeInsets = .zero {
        didSet {
            mainStack.removeFromSuperview()
            bgImage.addSubview(mainStack)
            mainStack.fixedEdgesConstraints(on: bgImage, inset: mainStackEdgesConstraints)
            if let bttm = mainStack.customBottomAnchorConstraint {
                mainStack.removeConstraint(bttm)
            }
            mainStack.customBottomAnchorConstraint = mainStack.bottomAnchor.constraint(greaterThanOrEqualTo: bgImage.bottomAnchor)
            mainStack.customBottomAnchorConstraint?.isActive = true
        }
    }
    
    override func setUp() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.fixedEdgesConstraints(on: view, inset: scrollViewEdgesConstraints)
        scrollView.addSubview(bgImage)
        bgImage.fixedEdgesConstraints(on: scrollView, inset: bgImageEdgesConstraints)
        if let trc = bgImage.customTrailingAnchorConstraint {
            bgImage.removeConstraint(trc)
        }
        bgImage.customTrailingAnchorConstraint = bgImage.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor)
        bgImage.customTrailingAnchorConstraint?.isActive = true
        bgImage.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor).isActive = true
        bgImage.addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: bgImage, inset: mainStackEdgesConstraints)
        if let bttm = mainStack.customBottomAnchorConstraint {
            mainStack.removeConstraint(bttm)
        }
        bgImage.isUserInteractionEnabled = true
        
        mainStack.customBottomAnchorConstraint = mainStack.bottomAnchor.constraint(greaterThanOrEqualTo: bgImage.bottomAnchor, constant: -Constants.inset)
        mainStack.customBottomAnchorConstraint?.isActive = true
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(subTitleLabel)
    }
}
