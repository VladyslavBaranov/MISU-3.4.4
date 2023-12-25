//
//  SymptomsPatientTabelViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension SymptomsPatientEditView: UITableViewDelegate, UITableViewDataSource {
    private var symptomsTableData: [SymptomModel] {
        return ListDHUSingleManager.shared.sympthoms
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptomsTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text = symptomsTableData[safe: indexPath.row]?.name
        cell.textLabel?.font = .systemFont(ofSize: 16)
        if let imgLink = symptomsTableData[safe: indexPath.row]?.imageLink {
            cell.imageView?.setImage(url: imgLink)
        }
        cell.accessoryType = .none
        if selectedSymptoms.firstIndex(of: symptomsTableData[indexPath.row].name ?? "") != nil {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedIndex = selectedSymptoms.firstIndex(of: symptomsTableData[indexPath.row].name ?? "") {
            selectedSymptoms.remove(at: selectedIndex)
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
            selectedSymptoms.append(symptomsTableData[indexPath.row].name ?? "")
        }
    }
}
