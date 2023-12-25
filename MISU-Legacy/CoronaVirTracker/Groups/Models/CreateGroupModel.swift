//
//  CreateGroupModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct CreateGroupModel {
    var name: String = ""
    var members: [String] = []
    
    enum Keys: String {
        case name = "name"
        case members = "member"
        case receiver = "receiver"
    }
    
    init(name nm: String = "", members mm: [String]) {
        name = nm
        members = mm
    }
    
    func getParams(isIvite: Bool = false) -> Parameters {
        var p: Parameters = [:]
        if !name.isEmpty, !isIvite {
            p.updateValue(name, forKey: Keys.name.rawValue)
        }
        if !members.isEmpty {
            if isIvite, let mem = members.first {
                p.updateValue(mem, forKey: Keys.receiver.rawValue)
            } else {
                p.updateValue(members, forKey: Keys.members.rawValue)
            }
        }
        //print("### p: \(p)")
        return p
    }
}
