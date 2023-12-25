//
//  MessageStatusEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum MessageStatusEnum: Int, CaseIterable {
    case notSended = 0
    case sending = 1
    case sended = 2
    case readed = 3
    
    static func getBy(_ id: Int) -> MessageStatusEnum? {
        return self.allCases[safe: id]
    }
}
