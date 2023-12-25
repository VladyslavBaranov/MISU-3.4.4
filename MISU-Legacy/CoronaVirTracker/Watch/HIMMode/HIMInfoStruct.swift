//
//  HIMInfoStruct.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 13.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum HIMInfoStruct: String, CaseIterable {
    case general = "Intensive health monitoring - a mode in which your health (heart rate and temperature) will be scanned more often"
    //"Інтенсивний моніторинг здоров’я - режим в якому показники вашого здоров'я (серцебиття та температура) будуть скануватись частіше"
    case notifocations = "Your family doctor and users in your family group will be alerted if the readings are out of range"
    //"Ваш сімейний лікар та користувачі з вашої сімейної групи будуть попереджені у випадку якщо показники виходять за межі норми"
    case battery = "In order for the mode to work, you must provide access to the VPN and not turn off the VPN in the settings. VPN makes connection between servers, MISU  and MISUWatch more stable and safe"
    //"Для роботи режиму необхідно надати доступ до VPN та не вимикати VPN в налаштуваннях телефону"
    
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
        case .general:
            return "generalHIMIcon"
        case .notifocations:
            return "notifocationsHIMIcon"
        case .battery:
            return "batteryHIMIcon"
        }
    }
}
