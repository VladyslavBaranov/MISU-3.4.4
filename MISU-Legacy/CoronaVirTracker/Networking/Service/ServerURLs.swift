//
//  ServerURLs.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 10/31/19.
//  Copyright © 2019 WHAR. All rights reserved.
//  http://134.122.82.54:8000/
//  192.168.43.6:8000/api/indicators/temperature?date_range=1

import Foundation

struct ServerURLs {
    static let misuDomSec = "https://misu.pp.ua/"
    static let misuDomNoneSec = "http://misu.pp.ua/"
    static let mainDrop = "http://134.122.82.54:8000/"
    static let sofiLocal = "http://192.168.42.48:8000/"
    static let sofiNES = "http://192.168.42.84:8000/"
    
    static var base: String { get { return misuDomSec } } //sofiNES }}

    static var api: String {
        get {
            return base + "api/"
        }
    }
    static var auth: String {
        get {
            return base + "auth/"
        }
    }
    static var messages: String {
        get {
            return base + "messages/"
        }
    }
}
