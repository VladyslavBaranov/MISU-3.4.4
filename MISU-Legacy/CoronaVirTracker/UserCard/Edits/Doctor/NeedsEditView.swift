//
//  NeedsEditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 24.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class NeedsEditView: EditView {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("What does your hospital need? \nOr mark the received resources", comment: ""), fontSize: 16, color: .black, alignment: .center)
    let needsTableView: UITableView = .createTableView()
    let addButton: UIButton = .createCustomButton(title: NSLocalizedString("Add", comment: ""), color: .white, fontSize: 16, shadow: false, customContentEdgeInsets: false)
    
    var needsDataList: [NeedsModel] = []
    let cellId = "cellId"
}
 


// MARK: - Overrides
extension NeedsEditView {
    override func setUpAdditionalViews() {
        dataSetUp()
        setUpLabel()
        setUpTableView()
        setUpButton()
    }
    
    override func saveAction() -> Bool {
        let old = UCardSingleManager.shared.user
        UCardSingleManager.shared.user.doctor?.setNeedsFrom(list: needsDataList)
        UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true)  { success in
            if success { DispatchQueue.main.async { self.completionAction?(true) } }
        }
        return true
    }
}



// MARK: - action methods
extension NeedsEditView {
    @objc private func addButtonAction(sender: UIView?) {
        let menuController = UIAlertController(title: NSLocalizedString("New need", comment: ""), message: nil, preferredStyle: .alert)
        menuController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        menuController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Name", comment: "")
        }
        menuController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Count", comment: "")
            textField.keyboardType = .numberPad
        }
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { _ in
            guard let name = menuController.textFields?.first?.text, !name.isEmpty else { return }
            var need = NeedsModel(name: name)
            if let countText = menuController.textFields?[1].text {
                need.count = Int(countText)
            }
            let insertingIndexPath = IndexPath(row: 0, section: 0)
            self.needsDataList.insert(need, at: insertingIndexPath.row)
            if self.needsTableView.numberOfRows(inSection: insertingIndexPath.section) > 0 {
                self.needsTableView.scrollToRow(at: insertingIndexPath, at: .top, animated: true)
            }
            self.needsTableView.insertRows(at: [insertingIndexPath], with: .top)
        }))
        
        menuController.popoverPresentationController?.sourceView = sender
        
        UIApplication.shared.delegate?.window??.rootViewController?.present(menuController, animated: true, completion: {
            if UIApplication.shared.delegate?.window??.subviews.last == self, let count = UIApplication.shared.delegate?.window??.subviews.count {
                UIApplication.shared.delegate?.window??.exchangeSubview(at: count-1, withSubviewAt: count-2)
            }
        })
    }
}



// MARK: - Additional views set up
extension NeedsEditView {
    private func dataSetUp() {
        needsDataList = UCardSingleManager.shared.user.doctor?.getNeedsList() ?? []
    }
    
    private func setUpLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
    }
    
    private func setUpTableView() {
        contentView.addSubview(needsTableView)
        needsTableView.delegate = self
        needsTableView.dataSource = self
        needsTableView.cornerRadius = 10
        needsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset).isActive = true
        needsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        needsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        needsTableView.heightAnchor.constraint(equalToConstant: self.frame.height*0.6).isActive = true
    }
    
    private func setUpButton() {
        contentView.addSubview(addButton)
        
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        
        addButton.topAnchor.constraint(equalTo: needsTableView.bottomAnchor, constant: standartInset).isActive = true
        addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
    }
}
