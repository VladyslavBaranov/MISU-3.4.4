//
//  UserTypeEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 19.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum UserTypeEnum: Int, CaseIterable {
    case patient = 0
    case doctor = 1
    case familyDoctor = 2
    
    var key: String {
        return String(describing: self)
    }
    
    static func getBy(_ id: Int) -> UserTypeEnum {
        guard let type = self.allCases.first(where: { $0.rawValue == id }) else {
            return .patient
        }
        return type
    }
    
    static func determine(_ user: UserModel) -> UserTypeEnum? {
        if let doc = user.doctor {
            if let docPost = doc.docPost, (docPost.name == "Сімейний лікар" || docPost.name == "Сімейний Лікар" || docPost.name == "сімейний лікар" || docPost.name == "Family doctor") {
                return .familyDoctor
            }
            return.doctor
        }
        return .patient
    }
}
