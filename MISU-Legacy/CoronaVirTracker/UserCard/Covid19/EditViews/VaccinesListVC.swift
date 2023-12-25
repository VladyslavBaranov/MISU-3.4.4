//
//  VaccinesListVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 22.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class VaccinesListVC: PresentUIViewController {
    let tableView: UITableView = .createTableView()
    let cellId = "vaccinesListCellId"
    var vaccinesList: [VaccineModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
}

extension VaccinesListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let vaccine = vaccinesList[safe: indexPath.row] else { return }
        
        let menuController = UIAlertController(
            title: NSLocalizedString("Delete \(vaccine.name ?? "") \(vaccine.date?.getDate() ?? "")", comment: "")+"?",
            message: nil, preferredStyle: .actionSheet)
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { _ in
            self.deleteVaccine(vaccine)
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        menuController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        present(menuController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccinesList.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = vaccinesList[safe: indexPath.row]?.name
        cell.detailTextLabel?.text = vaccinesList[safe: indexPath.row]?.date?.getDate()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vaccinesList.isEmpty ? NSLocalizedString("There is no added vaccines", comment: "") : NSLocalizedString("List of your vaccines:", comment: "")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.standart24Inset*2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return .init()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    }
}

extension VaccinesListVC: RequestUIController {
    func uniqeKeyForStore() -> String? { return view.getAddress() }
    
    func deleteVaccine(_ vaccine: VaccineModel) {
        prepareViewsBeforReqest(activityView: tableView)
        CovidManager.shared.deleteVaccine(model: vaccine) { success, error_ in
            self.enableViewsAfterReqest()
            
            if success == true {
                print("Vaccine successfully deleted ...")
                DispatchQueue.main.async {
                    self.vaccinesList.removeAll(where: {$0.id == vaccine.id})
                }
            }
            
            if let er = error_ {
                print("Vaccine delete ERROR \(er)")
            }
            DispatchQueue.main.async {
                (self.presentingViewController as? CovidRiscView)?.getInfo()
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Value1TVCell.self, forCellReuseIdentifier: cellId)
        tableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: view.standartInset).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
