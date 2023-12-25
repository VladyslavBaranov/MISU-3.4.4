//
//  NewModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 08.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

struct NewModel {
    let id: Int?
    let coverImage: String?
    let coverImageLink: String?
    let link: String?
    let title: String?
    let info: String?
    let date: String?
    
    func getImage(_ completion: ((UIImage)->Void)? ) {
        guard let imgLink = coverImageLink else { return }
        let imageCache = ImageCM.shared.get(byLink: imgLink) { image in
            completion?(image)
        }
        if let img = imageCache {
            completion?(img)
        }
    }
}

extension NewModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case coverImage = "coverImage"
        case coverImageLink = "image"
        case link = "link"
        case title = "title"
        case info = "text"
        case date = "date"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try? container.decode(Int.self, forKey: .id)
        coverImage = try? container.decode(String.self, forKey: .coverImage)
        link = try? container.decode(String.self, forKey: .link)
        coverImageLink = try? container.decode(String.self, forKey: .coverImageLink)
        title = try? container.decode(String.self, forKey: .title)
        info = try? container.decode(String.self, forKey: .info)
        date = try? container.decode(String.self, forKey: .date)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(id, forKey: .id)
        try? container.encode(coverImage, forKey: .coverImage)
        try? container.encode(coverImageLink, forKey: .coverImageLink)
        try? container.encode(link, forKey: .link)
        try? container.encode(title, forKey: .title)
        try? container.encode(info, forKey: .info)
        try? container.encode(date, forKey: .date)
    }
}
