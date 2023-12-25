//
//  UISwitchExt.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

extension UISwitch {
    static func create() -> UISwitch {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }
}
