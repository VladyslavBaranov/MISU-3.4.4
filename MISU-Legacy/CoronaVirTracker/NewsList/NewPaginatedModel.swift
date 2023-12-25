//
//  NewPaginatedModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 01.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

class NewPaginatedModel: PaginatedModel<NewModel> {
    var currentRegion: String? = Locale.current.regionCode
    
    override init() {
        super.init()
    }
    
    enum Keys: String, CodingKey {
        case currentRegion = "currentRegion"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func encode() -> HTTPHeaders? {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(currentRegion, forKey: .currentRegion)
        
        //print("### container.dictionary \(container.dictionary)")
        return container.dictionary as? HTTPHeaders
    }
}
