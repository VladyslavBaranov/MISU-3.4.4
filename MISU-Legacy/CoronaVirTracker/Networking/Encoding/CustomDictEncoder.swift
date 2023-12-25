//
//  CustomDictEncoder.swift
//  MyNUWEE
//
//  Created by Dmytro Kruhlov on 01.02.2021.
//

import Foundation

// MARK: - Usage Example
/* init(group: String? = nil, week: Int? = nil, token: Bool = false,
         begin_date: Date? = nil, end_date: Date? = nil,
         event: Bool = false, single: Bool = false) {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        token ? try? container.updateValue(KeychainUtils.getCurrentUserToken(), forKey: .token, in: &params) : pass
        event ? try? container.updateValue(event, forKey: .event, in: &params) : pass
        single ? try? container.updateValue(single, forKey: .single, in: &params) : pass
        try? container.updateValue(group, forKey: .group, in: &params)
        try? container.updateValue(week, forKey: .week, in: &params)
        //print("encode begin_date?.getDateForRequest() \(begin_date?.getDateForRequest())")
        try? container.updateValue(begin_date?.getDateForRequest(), forKey: .begin_date, in: &params)
        try? container.updateValue(end_date?.getDateForRequest(), forKey: .end_date, in: &params)
    }
*/
protocol ParamsEncodeble {
    func encode() -> Parameters
}

class KeyedCustomEncoderContainer<Key: CodingKey> {
    var dictionary: Parameters = [:]
    
    init(keyedBy: Key.Type) { }
    
    func updateValue(_ value: Any?, forKey key: Key, in dict: inout Parameters) throws {
        guard let v = value else { throw EncoderError.nilValue }
        dict.updateValue(v, forKey: key.stringValue)
    }
    
    func updateValue(_ value: Any?, forKey key: Key) throws {
        try updateValue(value, forKey: key, in: &dictionary)
    }
    
    
    
    
    func updateNilValue(_ value: Any?, forKey key: Key, in dict: inout Parameters) {
        dict.updateValue(value as Any, forKey: key.stringValue)
    }
    
    func updateNilValue(_ value: Any?, forKey key: Key) {
        dictionary.updateValue(value as Any, forKey: key.stringValue)
    }
    
    enum EncoderError: Error {
        case nilValue
    }
}
