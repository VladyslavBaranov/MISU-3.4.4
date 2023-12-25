//
//  NeedsEditTableViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 24.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension NeedsEditView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needsDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CustomTableViewCell(style: .value1, reuseIdentifier: "\(cellId)\(indexPath)")
        if let c = tableView.dequeueReusableCell(withIdentifier: "\(cellId)\(indexPath)") as? CustomTableViewCell {
            cell = c
        }
        
        cell.textLabel?.text = needsDataList[indexPath.row].name
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.text = "-"
        cell.detailTextLabel?.textColor = .gray
        if let count = needsDataList[indexPath.row].count {
            cell.detailTextLabel?.text = String(count)
        }
        cell.accessoryType = (needsDataList[indexPath.row].done ?? false) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menuController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        let receivingTitle = (needsDataList[indexPath.row].done ?? false) ? "Unreceived" : "Received"
        
        menuController.addAction(UIAlertAction(title: NSLocalizedString(receivingTitle, comment: ""), style: .default, handler: { _ in
            self.needsDataList[indexPath.row].done = !(self.needsDataList[indexPath.row].done ?? false)
            tableView.reloadData()
        }))
        menuController.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { _ in
            self.needsDataList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }))
        
        menuController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        UIApplication.shared.customKeyWindow?.rootViewController?.present(menuController, animated: true, completion: {
            if UIApplication.shared.delegate?.window??.subviews.last == self, let count = UIApplication.shared.delegate?.window??.subviews.count {
                UIApplication.shared.delegate?.window??.exchangeSubview(at: count-1, withSubviewAt: count-2)
            }
        })
    }
}
