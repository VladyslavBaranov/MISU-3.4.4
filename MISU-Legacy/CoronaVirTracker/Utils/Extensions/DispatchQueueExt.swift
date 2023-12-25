//
//  DispatchQueueExt.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 10.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func background(_ background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

}
