//
//  UITableView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 10.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UITableView {
    static func createTableView(sectionHeaderTopPadding: CGFloat = 0) -> UITableView {
        let cl = UITableView()
        cl.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            cl.sectionHeaderTopPadding = sectionHeaderTopPadding
        }
        return cl
    }
}
