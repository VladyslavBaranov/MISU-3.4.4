//
//  WatchViewStruct.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 05.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

protocol EnumTVStruct: CaseIterable {
    var cellClass: AnyClass { get }
    static func registerCells(for tableView: UITableView)
}

extension EnumTVStruct where Self: EnumKit {
    var cellClass: AnyClass {
        return UITableViewCell.self
    }
    
    static func registerCells(for tableView: UITableView) {
        self.allCases.forEach { sCase in
            tableView.register(sCase.cellClass, forCellReuseIdentifier: sCase.key)
        }
    }
}

enum WatchViewStruct: Int, CaseIterable, EnumKit, EnumTVStruct {
    case header = 0
    case himm = 1
    case hParams = 2
    case charts = 3
    
    var numberOfRowsInSection: Int {
        switch self {
        case .header:
            return HeaderStruct.allCases.count
        case .himm:
            return HIMModeStruct.allCases.count
        case .hParams:
            return HParamsStruct.allCases.count
        case .charts:
            return ChartsStruct.allCases.count
        }
    }
    
    var SectionStruct: AnyObject {
        switch self {
        case .header:
            return HeaderStruct.self as AnyObject
        case .himm:
            return HIMModeStruct.self as AnyObject
        case .hParams:
            return HParamsStruct.self as AnyObject
        case .charts:
            return ChartsStruct.self as AnyObject
        }
    }
    
    static func registerCells(for tableView: UITableView) {
        allCases.forEach { sCase in
            (sCase.SectionStruct as? EnumTVStruct.Type)?.registerCells(for: tableView)
        }
    }
    
    enum HeaderStruct: Int, CaseIterable, EnumKit, EnumTVStruct {
        case general = 0
        
        var cellClass: AnyClass {
            switch self {
            case .general:
                return WatchHeaderHIMMTVCell.self
            }
        }
    }
    
    enum HIMModeStruct: Int, CaseIterable, EnumKit, EnumTVStruct {
        case switcher = 0
        
        var cellClass: AnyClass {
            switch self {
            case .switcher:
                return HIMModeCell.self
            }
        }
    }
    
    enum HParamsStruct: Int, CaseIterable, EnumKit, EnumTVStruct {
        //case forceReload = 0
        case hParams = 0
        
        var cellClass: AnyClass {
            switch self {
            //case .forceReload:
                //return CustomTVCell.self
            case .hParams:
                return HealthParamsTVCell.self
            }
        }
    }
    
    enum ChartsStruct: Int, CaseIterable, EnumKit, EnumTVStruct {
        case sleep = 0
        case heartBeat = 1
        case temperature = 2
        case bloodOxygen = 3
        case pressure = 4
        
        var headerParm: HeadersParamEnum {
            switch self {
            case .bloodOxygen:
                return .bloodOxygen
            case .heartBeat:
                return .heartBeat
            case .temperature:
                return .temperature
            case .pressure:
                return .pressure
            default:
                return .temperature
            }
        }
        
        var cellClass: AnyClass {
            switch self {
            case .sleep:
                return SleepWatchTVCell.self
            case .heartBeat, .temperature, .bloodOxygen, .pressure:
                return WatchChartTVCell.self
            }
        }
    }
    
}
