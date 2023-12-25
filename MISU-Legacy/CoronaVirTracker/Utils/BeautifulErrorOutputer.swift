//
//  BeautifulErrorOutputer.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 1/3/20.
//  Copyright © 2020 WHAR. All rights reserved.
//

import Foundation

public struct BeautifulOutputer {
    enum eType: String {
        case success = "Success"
        case error = "ERROR"
        case warning = "Warning"
    }
    
    enum Place: String {
        case imageLoader = "imageLoaderVC"
        case list = "ListVC"
        case map = "MapVC"
        case medicalID = "MedicalIDVC"
        case newsView = "NewsVC"
        case shortInfoView = "shortInfoView"
        case usersSingleM = "UsersCardsSingleManager"
        case registration = "Registration"
    }
    
    static func cPrint(type: eType, place: Place, message1: String, message2: String? = nil){
        print("================\(type.rawValue)================")
        NSLog("BeautifulErrorOutputer")
        print("\(type.rawValue)(\(place.rawValue)): \(message1) \n [\(message2 ?? "")]")
        print("=======================================")
    }
}
