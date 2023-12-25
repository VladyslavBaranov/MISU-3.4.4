//
//  SelectIllnessEditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 16.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SelectIllnessEditView: EditView {
    let symptomsTableView: UITableView = .createTableView()
    var selectedIll: String = ""
    
    let cellId = "cellId"
}
 


// MARK: - Overrides
extension SelectIllnessEditView {
    override func setUpAdditionalViews() {
        //self.addTapRecognizer(self, action: #selector(cancelButtonAction))
        dataSetUp()
        setUpTableView()
        saveButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
        saveButton.isHidden = true
    }
    
    override func saveAction() -> Bool {
        return true
    }
}



// MARK: - Collection Delegate, DataSource
extension SelectIllnessEditView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListDHUSingleManager.shared.illnessList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text = ListDHUSingleManager.shared.illnessList[safe: indexPath.row]?.name ?? "-"
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.accessoryType = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let sel = ListDHUSingleManager.shared.illnessList[safe: indexPath.row]?.name {
            selectedIll = sel
            saveButtonAction()
        }
    }
}



// MARK: - Additional views set up
extension SelectIllnessEditView {
    private func dataSetUp() {
        //selectedSymptoms = UCardSingleManager.shared.user.profile?.symptoms ?? []
    }
    
    private func setUpTableView() {
        contentView.addSubview(symptomsTableView)
        symptomsTableView.delegate = self
        symptomsTableView.dataSource = self
        symptomsTableView.cornerRadius = 10
        symptomsTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        symptomsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        symptomsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        symptomsTableView.heightAnchor.constraint(equalToConstant: self.frame.height*0.6).isActive = true
        symptomsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        symptomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
}

