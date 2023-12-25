//
//  CalibrationStruct.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 24.05.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum CalibrationStruct: String, CaseIterable {
    case measureTonom = "Intensive health monitoring - a mode in which your health (heart rate and temperature) will be scanned more often"
    case measureBracelet = "Your family doctor and users in your family group will be alerted if the readings are out of range"
    case done = "In order for the mode to work, you must provide access to the VPN and not turn off the VPN in the settings. VPN makes connection between servers, MISU  and MISUWatch more stable and safe"
    
    var key: String {
        return String(describing: self)
    }
    
    var localizableText: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    
    var imageName: String {
        switch self {
        case .measureTonom:
            return "deviceCalibTonom"
        case .measureBracelet:
            return "infoCalibBracUkr"
        case .done:
            return "doneFamIcon"
        }
    }
    
    var textColor: UIColor {
        return .black
    }
}
