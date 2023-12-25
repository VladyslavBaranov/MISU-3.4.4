//
//  GenderEnum.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/17/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum SexEnum: String, CaseIterable {
    case man = "Man"
    case notSelected = "-"
    case woman = "Woman"
    
    init(num: Int) {
        switch num {
        case 0:
            self = .man
        case 1:
            self = .woman
        default:
            self = .notSelected
        }
    }
    
    init(forScrollId num: Int) {
        switch num {
        case 0:
            self = .man
        case 1:
            self = .notSelected
        case 2:
            self = .woman
        default:
            self = .notSelected
        }
    }
    
    var valueForRequest: Int? {
        switch self {
        case .man:
            return 0
        case .woman:
            return 1
        default:
            return nil
        }
    }
    
    var idForScroll: Int {
        get {
            switch self {
            case .man:
                return 0
            case .notSelected:
                return 1
            case .woman:
                return 2
            }
        }
    }
    
    var id: Int {
        get {
            switch self {
            case .man:
                return 0
            case .notSelected:
                return 3
            case .woman:
                return 1
            }
        }
    }
    
    var localizeble: String {
        get {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    static func translate(from: Gender) -> SexEnum {
        switch from {
        case .female:
            return .woman
        case .male:
            return .man
        default:
            return .notSelected
        }
    }
    
    func translate() -> Gender {
        switch self {
        case .man:
            return .male
        case .woman:
            return .female
        default:
            return .none
        }
    }
}

enum Gender: Int, CaseIterable {
    case male = 0
    case female = 1
    case all = 2
    case none = 3
    
    var key: String {
        return String(describing: self)
    }
    
    static func get(_ id: Int) -> Gender {
        switch id {
        case 0:
            return Gender.male
        case 1:
            return Gender.female
        case 2:
            return Gender.all
        case 3:
            return Gender.none
        default:
            return Gender.none
        }
    }
    
    var localized: String {
        switch self {
        default: return NSLocalizedString(self.key, comment: "")
        }
    }
}
