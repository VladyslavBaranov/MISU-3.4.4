//
//  LinkUtils.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 10/31/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

class LinkUtils {
    static func getCleanImagePath(link: String) -> String {
        var path = link.replacingOccurrences(of: ServerURLs.base, with: "")
            .replacingOccurrences(of: ServerURLs.misuDomNoneSec, with: "")
        if (path.prefix(1) == "/") {
            path = String(path.dropFirst())
        }
        return path
    }
}
