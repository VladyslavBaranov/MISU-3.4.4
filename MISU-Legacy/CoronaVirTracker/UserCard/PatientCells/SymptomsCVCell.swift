//
//  SymptomsCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 16.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class SymptomsCVCell: UICollectionViewCell {
    let mainStack: UIStackView = .createCustom(axis: .horizontal, spacing: 8, alignment: .center)
    let iconImage: UIImageView = .makeImageView("hCaseIcon", contentMode: .scaleAspectFit)
    let textLabel: UILabel = .createTitle(text: NSLocalizedString("Symptoms", comment: ""),
                                          color: .lightGray, alignment: .center)
    let subIconImage: UIImageView = .makeImageView(UIImage.init(systemName: "plus"), contentMode: .scaleAspectFit,
                                                   withRenderingMode: .alwaysTemplate, tintColor: UIColor.appDefault.redNew)
    
    let symptomsTV: UITableView = .createTableView()
    
    var userModel: UserModel? {
        didSet {
            let symp = userModel?.profile?.symptoms ?? []
            isSymptoms(!symp.isEmpty)
            symptomsData = symp
            symptomsTV.reloadData()
        }
    }
    
    var symptomsData: [String] = []
    let sympCellId = "sympCellId"
    
    init() {
        super.init(frame: .zero)
    }
    
    func isSymptoms(_ isSymp: Bool) {
        if isSymp {
            mainStack.animateFade(duration: 0)
            symptomsTV.animateShow(duration: 0)
            return
        }
        mainStack.animateShow(duration: 0)
        symptomsTV.animateFade(duration: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSetUp()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
extension SymptomsCVCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        goToEdit()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptomsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sympCellId, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = symptomsData[safe: indexPath.row]
        if let imgUrl = ListDHUSingleManager.shared.sympthoms.first(
            where: {$0.name == symptomsData[safe: indexPath.row]}
        )?.imageLink {
            cell.imageView?.setImage(url: imgUrl)
            let const = standartInset/2
            (cell as? CustomTableViewCell)?.imageEdgeInsets = .init(top: const, left: const/2, bottom: const, right: const/2)
            (cell as? CustomTableViewCell)?.leftTextInset = -standartInset
        }
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = symptomsData[safe: indexPath.row]
        if let imgUrl = ListDHUSingleManager.shared.sympthoms.first(
            where: {$0.name == symptomsData[safe: indexPath.row]}
        )?.imageLink {
            cell.imageView?.setImage(url: imgUrl)
            let const = standartInset/2
            (cell as? CustomTableViewCell)?.imageEdgeInsets = .init(top: const, left: const/2, bottom: const, right: const/2)
        }
    }*/
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let v = UIView()
            v.backgroundColor = .clear
            return UIView()
        }
}

extension SymptomsCVCell {
    @objc func goToEdit() {
        if userModel?.isCurrent == false { return }
        
        let frameForEdits = controller()?.view.frame ?? .zero
        let editView = SymptomsPatientEditView(frame: frameForEdits)
        editView.show { _ in
            (self.controller() as? ProfileVC)?.reloadUserProfile(request: false)
        }
    }
    
    private func initSetUp() {
        backgroundColor = .white
        setCustomCornerRadius()
        addCustomShadow()
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        addSubview(mainStack)
        addSubview(symptomsTV)
        
        mainStack.addArrangedSubview(iconImage)
        mainStack.addArrangedSubview(textLabel)
        mainStack.addArrangedSubview(subIconImage)
        let iconsSize = textLabel.font.lineHeight*1.5
        iconImage.heightAnchor.constraint(equalToConstant: iconsSize).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: iconsSize).isActive = true
        
        subIconImage.widthAnchor.constraint(equalToConstant: iconsSize).isActive = true
        subIconImage.widthAnchor.constraint(equalToConstant: iconsSize).isActive = true
        
        mainStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mainStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: standartInset/2).isActive = true
        mainStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -standartInset/2).isActive = true
        mainStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: standartInset/2).isActive = true
        mainStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -standartInset/2).isActive = true
        
        symptomsTV.delegate = self
        symptomsTV.dataSource = self
        symptomsTV.register(CustomTableViewCell.self, forCellReuseIdentifier: sympCellId)
        
        symptomsTV.separatorStyle = .none
        symptomsTV.backgroundColor = .clear
        symptomsTV.setCustomCornerRadius()
        symptomsTV.alwaysBounceVertical = true
        symptomsTV.animateFade(duration: 0)
        
        symptomsTV.topAnchor.constraint(equalTo: topAnchor).isActive = true
        symptomsTV.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        symptomsTV.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        symptomsTV.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    
    static func getHeight() -> CGFloat {
        return 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

