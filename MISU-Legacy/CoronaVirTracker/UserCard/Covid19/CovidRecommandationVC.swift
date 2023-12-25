//
//  CovidRecommandationVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CovidRecommandationVC: PresentUIViewController {
    let scrollView: UIScrollView = .create(bounces: true)
    let mainStack: UIStackView = .createCustom(axis: .vertical, spacing: 16)
    
    let titleImage: UIImageView = .makeImageView("covidProfImage")
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Prevention of Covid-19", comment: ""), fontSize: 24, weight: .semibold, alignment: .center, numberOfLines: 3)
    
    let paragraphLabel: UILabel = .createTitle(text: "", fontSize: 16)
    let finishButton: UIButton = .createCustom(title: NSLocalizedString("Okay", comment: ""), color: UIColor.appDefault.redNew)
    
    var infoType: CovidInfoEnum = .noRisk
}

extension CovidRecommandationVC {
    func setText() {
        titleImage.image = infoType.image
        titleLabel.text = infoType.ttLocalized
        paragraphLabel.attributedText = infoType.attributedText
    }
    
    override func setUp() {
        super.setUp()
        cancelButton.removeFromSuperview()
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)
        mainStack.addArrangedSubview(titleImage)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(paragraphLabel)
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.standartInset).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: view.standartInset).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -view.standartInset).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -view.standartInset).isActive = true
        
        paragraphLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        paragraphLabel.textColor = UIColor(red: 0.287, green: 0.287, blue: 0.287, alpha: 1)
        paragraphLabel.numberOfLines = 0
        paragraphLabel.lineBreakMode = .byWordWrapping
        setText()
        
        mainStack.addArrangedSubview(finishButton)
        finishButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        finishButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
    }
}
