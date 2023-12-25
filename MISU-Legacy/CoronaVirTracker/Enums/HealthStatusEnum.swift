//
//  HealthStatus.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/15/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

enum HealthStatusEnum: Int, CaseIterable {
    case well = 0
    case weak = 1
    case ill = 2
    
    var key: String { return String(describing: self) }
    
    var localized: String {
        get { return NSLocalizedString(self.key, comment: "") }
    }
    
    var imageName: String {
        get {
            switch self {
            case .well:
                return "greenHealthSmile"
            case .weak:
                return "yellowHealthSmile"
            case .ill:
                return "redHealthSmile"
            }
        }
    }
    
    func getSmileImage() -> UIImage? {
        return UIImage(named: self.imageName)
    }
    
    func getImage() -> UIImage? {
        switch self {
        case .well:
            return UIImage(named: "greenHealthPin")
        case .ill:
            return UIImage(named: "redHealthPin")
        case .weak:
            return UIImage(named: "yellowHealthPin")
        }
    }
    
    static func getBy(id: Int) -> HealthStatusEnum? {
        return HealthStatusEnum.allCases[safe: id]
    }
    
    static func randomItem() -> HealthStatusEnum {
        return HealthStatusEnum.allCases.randomElement() ?? .well
    }
    
    var old: HealthStatus {
        switch self {
        case .well:
            return .well
        case .weak:
            return .weak
        case .ill:
            return .ill
        }
    }
}


enum HealthStatus: Int, CaseIterable {
    case well = 0
    case weak = 1
    case ill = 2
    case dead = 3
    case all = 4
    
    var localized: String {
        get { return NSLocalizedString(self.key, comment: "") }
    }
    
    func getImage() -> UIImage? {
        switch self {
        case .well:
            return UIImage(named: "greenHealthPin")
        case .ill:
            return UIImage(named: "redHealthPin")
        case .weak:
            return UIImage(named: "yellowHealthPin")
        case .dead:
            return UIImage(named: "blackPoint")
        default:
            return UIImage(named: "greenHealthPin")
        }
    }
    
    static func get(_ id: Int?) -> HealthStatus? {
        switch id {
        case 0:
            return HealthStatus.well
        case 1:
            return HealthStatus.weak
        case 2:
            return HealthStatus.ill
        case 3:
            return HealthStatus.dead
        default:
            return nil
        }
    }
    
    static func randomItem() -> HealthStatus {
        let randIndex = Int.random(in: 0...self.ill.rawValue)
        return HealthStatus.allCases[randIndex]
    }
    
    var key: String {
        return String(describing: self)
    }
    
    var new: HealthStatusEnum {
        switch self {
        case .well:
            return .well
        case .weak:
            return .weak
        case .ill:
            return .ill
        default:
            return .well
        }
    }
}
