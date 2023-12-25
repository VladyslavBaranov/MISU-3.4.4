//
//  BasePaginatedModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 19.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

class PaginatedModel<T: Decodable>: Decodable {
    var currentPage: Int = 0
    var pages: Int = 0
    var list: [T] = []
    
    internal enum PKeys: String, CodingKey {
        case currentPage = "page"
        case pages = "pages"
        case list = "list"
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PKeys.self)
        
        currentPage = (try? container.decode(Int.self, forKey: .currentPage)) ?? 0
        pages = (try? container.decode(Int.self, forKey: .pages)) ?? 0
        list = (try? container.decode([T].self, forKey: .list)) ?? []
    }
    
    func nextPageURLParams() -> Parameters {
        return [PKeys.currentPage.rawValue:currentPage+1]
    }
}
