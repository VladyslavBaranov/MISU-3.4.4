//
//  NeedsHavesCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.04.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class NeedsHavesCVCell: CustomCVCell {
    let leftTitle: UILabel = .createTitle(text: "-", fontSize: 16, color: UIColor.appDefault.redNew)
    let plusImage: UIImageView = .makeImageView(UIImage(systemName: "plus"), withRenderingMode: .alwaysTemplate, tintColor: UIColor.appDefault.redNew)
    let mainTV: UITableView = .createTableView()
    let cellId: String = "needsHavesCellId"
    
    var needItems: [NeedsModel] {
        didSet {
            leftTitle.text = NSLocalizedString("We need", comment: "")
            leftTitle.textColor = UIColor.appDefault.redNew
            itemsList = needItems
        }
    }
    
    var haveItems: [NeedsModel] {
        didSet {
            leftTitle.text = NSLocalizedString("We have", comment: "")
            leftTitle.textColor = UIColor.appDefault.green
            itemsList = haveItems
        }
    }
    
    var itemsList: [NeedsModel] {
        didSet {
            mainTV.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        needItems = []
        haveItems = []
        itemsList = []
        super.init(frame: frame)
        
        setUp()
    }
    
    func setUp() {
        backgroundColor = .white
        setCustomCornerRadius()
        addCustomShadow()
        
        addSubview(leftTitle)
        addSubview(plusImage)
        addSubview(mainTV)
        
        leftTitle.topAnchor.constraint(equalTo: topAnchor, constant: standartInset).isActive = true
        leftTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset).isActive = true
        leftTitle.trailingAnchor.constraint(equalTo: plusImage.leadingAnchor, constant: -standartInset).isActive = true
        
        leftTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
        leftTitle.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        leftTitle.setContentHuggingPriority(.init(100), for: .horizontal)
        leftTitle.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        
        plusImage.centerYAnchor.constraint(equalTo: leftTitle.centerYAnchor).isActive = true
        plusImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset).isActive = true
        plusImage.heightAnchor.constraint(equalTo: leftTitle.heightAnchor, multiplier: 0.8).isActive = true
        plusImage.widthAnchor.constraint(equalTo: leftTitle.heightAnchor, multiplier: 0.8).isActive = true
        
        mainTV.topAnchor.constraint(equalTo: leftTitle.bottomAnchor, constant: standartInset).isActive = true
        mainTV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset).isActive = true
        mainTV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset).isActive = true
        mainTV.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standartInset).isActive = true
        
        mainTV.delegate = self
        mainTV.dataSource = self
        mainTV.separatorStyle = .none
        mainTV.register(Value1TVCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func getSize(cv: UICollectionView) -> CGSize {
        return .init(width: cv.frame.width - cv.standartInset,
                     height: cv.frame.width/2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NeedsHavesCVCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = itemsList[safe: indexPath.row]?.name
        if let cnt = itemsList[safe: indexPath.row]?.count {
            cell.detailTextLabel?.text = "\(cnt)"
        } else {
            cell.detailTextLabel?.text = "-"
        }
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        if (controller() as? ProfileVC)?.userModel?.isCurrent == false { return }
        
        let frameForEdits = controller()?.view.frame ?? .zero
        let editView = NeedsEditView(frame: frameForEdits)
        editView.show { _ in
            (self.controller() as? ProfileVC)?.profileCollectionView.reloadData()
        }
    }
}
