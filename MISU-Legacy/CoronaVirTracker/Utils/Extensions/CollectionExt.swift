//
//  CollectionExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 14.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
