//
//  HospitalListModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 05.01.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

class HospitalListModelT: PaginatedModel<HospitalModel> {
    var city: String?
    var searchWord: String?
    
    private enum Keys: String, CodingKey {
        case city = "city"
        case word = "word"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: Keys.self)
        
        city = try? container.decode(String.self, forKey: .city)
    }
    
    override func nextPageURLParams() -> Parameters {
        var p = super.nextPageURLParams()
        if let _city = city, !_city.isEmpty {
            p.updateValue(_city, forKey: Keys.city.rawValue)
        }
        return p
    }
    
    func searchBodyParams() -> Parameters {
        if let word = searchWord, !word.isEmpty {
            return [Keys.word.rawValue:word]
        }
        return [:]
    }
    
    func searchUrlParams() -> Parameters {
        return [PKeys.currentPage.rawValue:currentPage+1]
    }
}

struct HospitalListModel {
    var city: String? = nil
    var currentPage: Int = 0
    var pages: Int = 0
    var list: [HospitalModel] = []
    
    var searchWord: String?
}

extension HospitalListModel {
    func nextPageParams() -> Parameters {
        var p: Parameters = [Keys.currentPage.rawValue:currentPage+1]
        if let _city = city, !_city.isEmpty {
            p.updateValue(_city, forKey: Keys.city.rawValue)
        }
        return p
    }
    
    func searchUrlParams() -> Parameters {
        return [Keys.currentPage.rawValue:currentPage+1]
    }
    
    func searchBodyParams() -> Parameters {
        var p: Parameters = [:]
        if let word = searchWord, !word.isEmpty {
            p.updateValue(word, forKey: Keys.word.rawValue)
        }
        return p
    }
}

extension HospitalListModel: Codable {
    private enum Keys: String, CodingKey {
        case city = "city"
        case currentPage = "page"
        case pages = "pages"
        case list = "list"
        case word = "word"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        city = try? container.decode(String.self, forKey: .city)
        currentPage = (try? container.decode(Int.self, forKey: .currentPage)) ?? 0
        pages = (try? container.decode(Int.self, forKey: .pages)) ?? 0
        list = (try? container.decode([HospitalModel].self, forKey: .list)) ??
               (try? decoder.singleValueContainer().decode([HospitalModel].self)) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(city, forKey: .city)
        try? container.encode(currentPage, forKey: .currentPage)
        try? container.encode(pages, forKey: .pages)
        try? container.encode(list, forKey: .list)
    }
}
