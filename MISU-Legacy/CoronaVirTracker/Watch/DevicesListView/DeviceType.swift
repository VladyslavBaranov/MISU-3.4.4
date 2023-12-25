//
//  DeviceType.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 21.10.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

enum DeviceType: Int, CaseIterable, EnumKit {
    case TrusangZHJBT = 0
    case AppleHK = 1
    
    var manager: WatchManager {
        switch self {
        case .TrusangZHJBT:
            return WatchSinglManager.shared
        case .AppleHK:
            return HealthKitAssistant.shared
        }
    }
    
    var view: DeviceView {
        switch self {
        case .TrusangZHJBT:
            let dv = MISUWatchV1View()
            dv.deviceType = self
            return dv
        case .AppleHK:
            let dv = DeviceView()
            dv.deviceType = self
            dv.iconImage.image = UIImage(named: "apple-black-logo")
            dv.nameLabel.text = "Apple Watch (Health Kit)"
            return dv
        }
    }
    
    static var basetHeight: CGFloat {
        return UIFont.systemFont(ofSize: 16).lineHeight*2.5
    }
        
    var defaultHeight: CGFloat {
        switch self {
        case .TrusangZHJBT:
            return DeviceType.basetHeight
        default:
            return DeviceType.basetHeight/2
        }
    }
}
