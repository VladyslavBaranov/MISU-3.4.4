//
//  SymptomsPatientEditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SymptomsPatientEditView: EditView {
    let symptomsLabel: UILabel = .createTitle(text: NSLocalizedString("Select Symptoms", comment: ""), fontSize: 14, color: .lightGray, alignment: .center)
    let symptomsTableView: UITableView = .createTableView()
    var selectedSymptoms: [String] = []
    
    let cellId = "cellId"
}
 


// MARK: - Overrides
extension SymptomsPatientEditView {
    override func setUpAdditionalViews() {
        //self.addTapRecognizer(self, action: #selector(cancelButtonAction))
        dataSetUp()
        setUpLabel()
        setUpTableView()
    }
    
    override func saveAction() -> Bool {
        if UCardSingleManager.shared.user.profile?.symptoms != selectedSymptoms {
            let old = UCardSingleManager.shared.user
            UCardSingleManager.shared.user.profile?.symptoms = selectedSymptoms
            UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                if success { DispatchQueue.main.async { self.completionAction?(true) } }
            }
        }
        return true
    }
}



// MARK: - Other methods
extension SymptomsPatientEditView {
    
}



// MARK: - Additional views set up
extension SymptomsPatientEditView {
    private func dataSetUp() {
        selectedSymptoms = UCardSingleManager.shared.user.profile?.symptoms ?? []
    }
    
    private func setUpLabel() {
        contentView.addSubview(symptomsLabel)
        symptomsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        symptomsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        symptomsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
    }
    
    private func setUpTableView() {
        contentView.addSubview(symptomsTableView)
        symptomsTableView.delegate = self
        symptomsTableView.dataSource = self
        symptomsTableView.cornerRadius = 10
        symptomsTableView.topAnchor.constraint(equalTo: symptomsLabel.bottomAnchor, constant: standartInset).isActive = true
        symptomsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        symptomsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        symptomsTableView.heightAnchor.constraint(equalToConstant: self.frame.height*0.6).isActive = true
        symptomsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        symptomsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellId)
    }
}
