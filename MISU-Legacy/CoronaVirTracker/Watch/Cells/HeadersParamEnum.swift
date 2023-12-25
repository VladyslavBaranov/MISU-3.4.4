//
//  HeadersParamEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 22.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum HeadersParamEnum: String, CaseIterable, EnumKit {
    case bloodOxygen = "O2WIcon"
    case heartBeat = "heartWatchIcon"
    case temperature = "temperatureWIcon"
    case pressure = "pressureWIcon"
    
    var index: Int? {
        return HeadersParamEnum.allCases.firstIndex(of: self)
    }
    
    var label: String {
        switch self {
        case .bloodOxygen:
            return "%"
        case .temperature:
            return "˚"
        default:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .bloodOxygen:
            return NSLocalizedString("Blood oxygen", comment: "")
        case .temperature:
            return NSLocalizedString("Temperature", comment: "")
        case .heartBeat:
            return NSLocalizedString("Heart rate", comment: "")
        case .pressure:
            return NSLocalizedString("Blood pressure", comment: "")
        }
    }
    var healthParamStruct: HealthParamsEnum {
        switch self {
        case .bloodOxygen:
            return .bloodOxygen
        case .temperature:
            return .temperature
        case .heartBeat:
            return .heartBeat
        case .pressure:
            return .pressure
        }
    }
    
    var watchChartsStruct: WatchViewStruct.ChartsStruct {
        switch self {
        case .bloodOxygen:
            return .bloodOxygen
        case .temperature:
            return .temperature
        case .heartBeat:
            return .heartBeat
        case .pressure:
            return .pressure
        }
    }
    
    var maxValue: Double {
        switch self {
        case .bloodOxygen:
            return 100
        case .temperature:
            return 41
        case .heartBeat:
            return 120
        case .pressure:
            return 180
        }
    }
    
    var minValue: Double {
        switch self {
        case .bloodOxygen:
            return 85
        case .temperature:
            return 32
        case .heartBeat:
            return 20
        case .pressure:
            return 40
        }
    }
    
    var lineColor: [UIColor] {
        switch self {
        case .bloodOxygen:
            return [UIColor.appDefault.blue]
        case .temperature:
            return [UIColor.appDefault.blackPrimary]
        case .heartBeat:
            return [UIColor.appDefault.red]
        case .pressure:
            return [UIColor(hexString: "DD284A"), UIColor(hexString: "FF2D55")]//imageIcon?.averageColor ?? UIColor.appDefault.red]
        }
    }
    
    var gradientFill: [CGGradient] {
        var gFill: [CGGradient] = []
        lineColor.forEach { clr in
            guard let grad = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                             colors: [clr.cgColor, UIColor.white.cgColor] as CFArray,
                                             locations: customGradLocation) else {
                return
            }
            gFill.append(grad)
        }
        return gFill
    }
    
    var customGradLocation: [CGFloat] {
        return [1.0, 0.0]
    }
    
    var imageIcon: UIImage? {
        return UIImage(named: self.rawValue)
    }
}
