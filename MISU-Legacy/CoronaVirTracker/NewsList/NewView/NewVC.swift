//
//  NewVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 16.09.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import SafariServices

// MARK: - Components
class NewVC: UIViewController {
    let scrollView: UIScrollView = .create()
    let contentView: UIView = .createCustom(bgColor: .white)
    let coverImage: UIImageView = .makeImageView("misuLogo", contentMode: .scaleAspectFill)
    let titleLabel: UILabel = .createTitle(text: "New title", fontSize: 24, weight: .bold)
    let infoLabel: UILabel = .createTitle(text: "Short info about new", fontSize: 18)
    let dateLabel: UILabel = .createTitle(text: "11.03.2020 16:00", fontSize: 16, color: .lightGray)
    
    let linkButton: UIButton = {
        let lb = UIButton(type: .system)
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        lb.setTitleColor(UIColor.appDefault.red, for: .normal)
        lb.setTitle("kolya.best.design.com", for: .normal)
        lb.titleLabel?.font = .systemFont(ofSize: 16)
        lb.contentHorizontalAlignment = .leading
        lb.titleLabel?.lineBreakMode = .byTruncatingTail
        
        return lb
    }()
    
    var newModel: NewModel?
}



// MARK: - View loads Overrides
extension NewVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpNavigationView()
        setUpScrollView()
        setUpNewViews()
        fillNewFields()
    }
    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationView()
    }
}



// MARK: - SetUp Methods
extension NewVC {
    func setUpView() {
        self.view.backgroundColor = UIColor.white
    }
    
    func setUpNavigationView() {
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setUpScrollView() {
        view.addSubview(scrollView)
        scrollView.contentSize = .zero
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor).isActive = true
    }
    
    func setUpNewViews() {
        scrollView.addSubview(contentView)
        contentView.addSubview(coverImage)
        contentView.addSubview(linkButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(dateLabel)
        
        linkButton.addTarget(self, action: #selector(openLinkAction), for: .touchUpInside)
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        coverImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImage.heightAnchor.constraint(equalToConstant: view.frame.height*0.4).isActive = true
        coverImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coverImage.setRoundedParticly(corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        //coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        linkButton.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: linkButton.standartInset).isActive = true
        linkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: linkButton.standartInset).isActive = true
        linkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -linkButton.standartInset).isActive = true
        //linkLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        titleLabel.numberOfLines = 5
        titleLabel.topAnchor.constraint(equalTo: linkButton.bottomAnchor, constant: linkButton.standartInset/2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabel.standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -titleLabel.standartInset).isActive = true
        //titleLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        
        infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: infoLabel.standartInset/2).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: infoLabel.standartInset).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -infoLabel.standartInset).isActive = true
        infoLabel.numberOfLines = 999
        
        dateLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: dateLabel.standartInset).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: dateLabel.standartInset).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -dateLabel.standartInset).isActive = true
        dateLabel.setContentCompressionResistancePriority(UILayoutPriority(1001), for: .vertical)
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -dateLabel.standartInset).isActive = true
    }
    
    func fillNewFields() {
        guard let new = newModel else {return}
        titleLabel.text = new.title ?? "-"
        infoLabel.text = new.info ?? "-"
        dateLabel.text = new.date?.toDate()?.getDateTime() ?? "-"
        linkButton.setTitle(new.link?.removeHTTPS() ?? "-", for: .normal)
        guard let lnk = new.coverImageLink else { return }
        coverImage.setImage(url: lnk, defaultImageName: "misuLogo")
        /*new.getImage { image in
            DispatchQueue.main.async { self.coverImage.image = image }
        }*/
    }
    
    @objc func openLinkAction() {
        guard let link = newModel?.link, let url = URL(string: link), link.lowercased().components(separatedBy: "http").count > 1 else {
            print("Wrong url ...")
            return
        }
        
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
}
