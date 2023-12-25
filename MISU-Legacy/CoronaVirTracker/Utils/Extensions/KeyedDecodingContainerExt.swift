//
//  KeyedDecodingContainerExt.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 13.12.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    func decode<T:Decodable>(forKey key: Self.Key) throws -> T {
        return try decode(T.self, forKey: key)
    }
    
    func decode<T:Decodable>(forKey key: Self.Key, defaultValue: T) -> T {
        guard let dValue = try? decode(T.self, forKey: key) else {
            return defaultValue
        }
        return dValue
    }
}
