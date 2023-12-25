//
//  CustomPhoneNumberTF.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 04.05.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import PhoneNumberKit

class CustomPhoneNumberTF: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            return "UA"
        }
        set {}
    }
    
    func alertAnimation(color: UIColor = UIColor.appDefault.red, duration: Double = 0.3) {
        self.animateShake(intensity: 3, duration: duration)
    }
}
