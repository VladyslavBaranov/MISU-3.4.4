//
//  MapCLLocationManagerDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import MapKit

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            print("No access")
            if let coord = UCardSingleManager.shared.user.location?.coordinate {
                mapView.setCenter(CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude), zoomLevel: 10, animated: true)
            } else {
                mapView.setCenter(.RivneCoord, zoomLevel: 10, animated: true)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
            
            guard let location = manager.location, UCardSingleManager.shared.user.location == nil else { return }
            print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
            
//            location.fetchCityAndCountry { city, country, error in
//                guard let city = city, let country = country, error == nil else { return }
//                let newLocation = LocationModel(city, city: city, country: country, coord: Coordinates(CLLCoord: location.coordinate))
//                UCardSingleManager.shared.user.location = newLocation
//                UCardSingleManager.shared.createLocation(location: newLocation)
                //UCardSingleManager.shared.saveCurrUser(еol)
//            }
             
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (response, error) in
                guard let placemakrs = response else {
                    print(String(describing: error))
                    return
                }
                
                if let place = placemakrs.first {
                    var name = ""
                    var city = ""
                    var country = ""
                    
                    if let nm = place.name {
                        name = nm
                    }
                    if let ct = place.locality {
                        city = ct
                    }
                    if let cntr = place.country {
                        country = cntr
                    }
                    
                    let adminCenter = place.administrativeArea
                    
                    let loc = LocationModel(name, city: city, country: country, adminArea: adminCenter, coord: Coordinates(CLLCoord: location.coordinate))
                    
                    let old = UCardSingleManager.shared.user
                    UCardSingleManager.shared.user.location = loc
                    UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true)
                    UCardSingleManager.shared.createLocation(location: loc)
                    //self.updateDataTarget()
                }
            }
        @unknown default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError ...")
        isUserLocation()
    }
}
