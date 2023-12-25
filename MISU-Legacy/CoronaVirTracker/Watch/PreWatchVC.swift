//
//  PreWatchVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 31.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import SafariServices

class PreWatchVC: UIViewController {
    let connectButton: UIButton = .createCustom(title: NSLocalizedString("Connect", comment: ""), color: UIColor.appDefault.red, fontSize: 18, textColor: .white, shadow: false)
    let buyButton: UIButton = .createCustom(title: NSLocalizedString("Get MISU Watch", comment: ""), color: .white, fontSize: 18, textColor: UIColor.appDefault.red, shadow: false)
    let imageView: UIImageView = .makeImageView("KeepCalmMISU")
    let titleLabel: UILabel = .createTitle(text: "MISU Watch", fontSize: 30, color: UIColor(hexString: "#494949"), alignment: .center)
    let subTitleLabel: UILabel = .createTitle(text: NSLocalizedString("Monitor your health easy and automatically", comment: ""),
                                              fontSize: 16, color: UIColor(hexString: "#494949"), alignment: .center)
    let watchesManager = WatchesController.shared
}



// MARK: - View loads overrides
extension PreWatchVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetUp()
        setUpNavigationView()
        setUpSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if KeychainUtils.getCurrentUserToken() == applePatToken {
            navigationController?.popViewController(animated: true)
        }
    }
}



// MARK: - Actions
extension PreWatchVC {
    @objc func connectButtonAction() {
        // go to connect
        //watchManager.listOfDevices()
        let devicesView = DevicesListModalView(frame: view.frame)
        devicesView.show { [self] _ in
            if watchesManager.wasConnectedAny {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func getWatchButtonAction() {
        let link = "https://misu.in.ua/#anchor1"
        guard let url = URL(string: link) else {
            print("Wrong url ...")
            return
        }
        UIApplication.shared.open(url)
    }
}



// MARK: - View Setups
extension PreWatchVC {
    func setUpSubViews() {
        view.addSubview(connectButton)
        view.addSubview(buyButton)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(imageView)
        
        buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.standartInset*1.5).isActive = true
        buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset*1.5).isActive = true
        buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset*1.5).isActive = true
        buyButton.addTarget(self, action: #selector(getWatchButtonAction), for: .touchUpInside)
        
        connectButton.bottomAnchor.constraint(equalTo: buyButton.topAnchor, constant: -view.standartInset).isActive = true
        connectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset*1.5).isActive = true
        connectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset*1.5).isActive = true
        connectButton.addTarget(self, action: #selector(connectButtonAction), for: .touchUpInside)
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.standartInset*3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset*1.5).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset*1.5).isActive = true
        
        subTitleLabel.numberOfLines = 3
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: view.standartInset*2).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset*1.5).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset*1.5).isActive = true
        
        
        imageView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: view.standartInset*3).isActive = true
        imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: view.standartInset*2).isActive = true
        imageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -view.standartInset*2).isActive = true
        imageView.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -view.standartInset*3).isActive = true
        imageView.setContentCompressionResistancePriority(.init(100), for: .vertical)
        imageView.setContentHuggingPriority(.init(100), for: .vertical)
        if UCardSingleManager.shared.user.number == "+380987680603" {
            imageView.image = UIImage(named: "NickAnime1")
        }
    }
    
    func viewSetUp() {
        view.backgroundColor = .white
    }

    func setUpNavigationView() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

