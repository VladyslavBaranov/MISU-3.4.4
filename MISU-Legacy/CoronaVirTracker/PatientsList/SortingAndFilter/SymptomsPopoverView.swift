//
//  SymptomsPopoverView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 15.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class SymptomsPopoverView: UIViewController {
    let symptomsTableView: UITableView = .createTableView()
    let allSymptoms: [String] = {
        var symptms: [String:Bool] = [:]
        ListDHUSingleManager.shared.users.forEach { user in
            user.profile?.symptoms.forEach({ symp in
                symptms.updateValue(false, forKey: symp)
            })
        }
        return Array(symptms.keys)
    }()
    let cellId = "cellIdSys"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .popover
        print(allSymptoms)
    }
    
    override func loadView() {
        view = symptomsTableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func setUpViews() {
        symptomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        symptomsTableView.delegate = self
        symptomsTableView.dataSource = self
        //let h: CGFloat = CGFloat(stVvs.count) * (switchViews.first?.frame.height ?? 1) + 48
        //let w: CGFloat = (switchViews.first?.frame.width ?? 0) + view.standartInset*3 + (labelWidts.max() ?? 0)
        preferredContentSize = .zero //.init(width: w, height: h)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension SymptomsPopoverView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSymptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = allSymptoms[safe: indexPath.row]
        cell.accessoryType = .none
        if PatientsVCStructEnum.selectedSympthoms.firstIndex(of: allSymptoms[indexPath.row]) != nil {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell.accessoryType == .checkmark {
            PatientsVCStructEnum.selectedSympthoms.removeAll(where: {$0 == allSymptoms[safe: indexPath.row]})
            cell.accessoryType = .none
        } else {
            PatientsVCStructEnum.selectedSympthoms.append(allSymptoms[indexPath.row])
            cell.accessoryType = .checkmark
        }
        
        PatientsVCStructEnum.patientsSortingDelegate?.sympthomsChanged(PatientsVCStructEnum.selectedSympthoms)
    }
}
