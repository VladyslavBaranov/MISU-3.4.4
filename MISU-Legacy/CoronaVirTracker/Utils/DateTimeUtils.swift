//
//  DateTimeUtils.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 10/10/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

class DateTimeUtils {
    static func getCurrentDateTime(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
