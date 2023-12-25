//
//  ModelEncodeUtils.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

protocol ModelEncodeUtils {
}

extension ModelEncodeUtils {
    func addOptionalTo(dict: inout [String:Any], value: Any?, key: String) {
        if let value = value {
            dict[key] = value
        }
    }
}
