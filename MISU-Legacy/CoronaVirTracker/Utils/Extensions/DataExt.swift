//
//  DataExt.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 2/18/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation

extension Data {
    private enum DataError: String, Error {
        case encodingStringToDataFailed = "Encoding String to Data failed ..."
    }
    
    mutating func appendString(_ string: String) throws {
        guard let data: Data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            throw DataError.encodingStringToDataFailed
        }
        append(data)
    }
}



extension NSMutableData {
    private enum NSMutableDataError: String, Error {
        case encodingStringToNSMutableDataFailed = "Encoding String to NSMutableData failed ..."
    }
    
    func appendString(_ string: String) throws {
        guard let data: Data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            throw NSMutableDataError.encodingStringToNSMutableDataFailed
        }
        append(data)
    }
}
