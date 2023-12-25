//
//  PatientsVCStruct.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 12.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum PatientsVCStructEnum: Int, CaseIterable {
    case sorting = 0
    case list = 1
    
    var key: String { get { return String(describing: self) } }
    var numberOfRows: Int {
        switch self {
        case .sorting:
            return SortingSEnum.allCases.count
        default:
            return 0
        }
    }
    
    enum SortingSEnum: Int, CaseIterable {
        case state = 0
        case temperature = 1
        case symptoms = 2
        
        var key: String { get { return String(describing: self) } }
        var title: String {
            get {
                if self == .symptoms, PatientsVCStructEnum.selectedSympthoms.count > 0 {
                    return "\(PatientsVCStructEnum.selectedSympthoms.count) " + NSLocalizedString(self.key, comment: "")
                }
                return NSLocalizedString(self.key, comment: "")
            }
        }
        var image: UIImage? {
            get {
                switch self {
                case .state:
                    if PatientsVCStructEnum.selectedStates.count == 0 || PatientsVCStructEnum.selectedStates.count == 3 {
                        return UIImage(named: "greyHealthSmile")
                    }
                    return UIImage(named: "greenHealthSmile")
                case .temperature:
                    if PatientsVCStructEnum.isAscending == true {
                        return UIImage(named: "UpArrow")
                    } else if PatientsVCStructEnum.isAscending == false {
                        return UIImage(named: "DownArrow")
                    }
                    return UIImage(named: "UpDownSortIcon")
                default:
                    return nil
                }
            }
        }
    }
    
    static var selectedStates: [HealthStatusEnum] = []
    static var selectedSympthoms: [String] = []
    static var isAscending: Bool? = nil
    
    static var patientsSortingDelegate: PatientsListSortingDelegate?
}

protocol PatientsListSortingDelegate {
    func statesChanged(_ states: [HealthStatusEnum])
    func temperatureOrderChanged(_ isAscending: Bool?)
    func sympthomsChanged(_ sympthoms: [String])
}
