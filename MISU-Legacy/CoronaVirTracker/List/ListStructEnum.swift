//
//  ListStructEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 08.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

enum ListStructEnum: Int, CaseIterable {
    case doctors = 0
    case hospitals = 1
    case users = 2
    
    func getItemDescription() -> String {
        switch self {
        case .doctors:
            return NSLocalizedString("Doctors", comment: "")
        case .hospitals:
            return NSLocalizedString("Hospitals", comment: "")
        case .users:
            return NSLocalizedString("Patients", comment: "")
        }
    }
    
    func getImage() -> UIImage? {
        switch self {
        case .doctors:
            return UIImage(named: "approvedDocStatus")
        case .hospitals:
            return UIImage(named: "hospitalIcon")
        case .users:
            return UIImage(named: "greenHealthPin")
        }
    }
        
    static func getItem(name: String?) -> ListStructEnum? {
        switch name {
        case ListStructEnum.doctors.getItemDescription():
            return .doctors
        case ListStructEnum.hospitals.getItemDescription():
            return .hospitals
        case ListStructEnum.users.getItemDescription():
            return .users
        default:
            return nil
        }
    }
}
