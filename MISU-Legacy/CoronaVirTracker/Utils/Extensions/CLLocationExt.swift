//
//  CLLocationExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/13/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import MapKit

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}

extension CLLocationCoordinate2D {
    static var RivneCoord: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: 50.619564, longitude: 26.251460)
        }
    }
}
