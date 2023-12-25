//
//  DictionaryMergeExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 29.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(with dic: [Key: Value]) {
        dic.forEach { (k, v) in updateValue(v, forKey: k) }
    }
}
