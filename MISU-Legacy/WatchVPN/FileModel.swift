//
//  FileModel.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 2/12/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation

public struct FileModel {
    let name: String
    let key: String
    let data: Data?
    let type: String
    
    init(name: String, type: FileType, data: Data?) {
        self.name = name
        self.data = data
        self.type = type.rawValue
        
        switch type {
        case .imageJpg:
            self.key = Keys.image.key
        default:
            self.key = Keys.file.key
        }
    }
}

extension FileModel {
    enum FileType: String {
        case imageJpg = "image/jpeg"
        case audioMp3 = "audio/mp3"
    }
    
    enum Keys {
        case image
        case file
        
        var key: String {
            return String(describing: self)
        }
    }
}
