//
//  MapTaskSingletonManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import Mapbox

class MapTaskSingletonManager {
    static let shared = MapTaskSingletonManager()
    private init() { }
    
    private var scaleToCoord: Coordinates?
    private let standartZoomLvL: Double = 16
    
    func doTask(_ mapView: MGLMapView) {
        guard let coords = scaleToCoord else { return }
        scaleToCoord = nil
        
        mapView.setCenter(coords.getCLLC2D(), zoomLevel: standartZoomLvL, animated: true)
        mapView.setCenter(coords.getCLLC2D(), zoomLevel: standartZoomLvL, direction: CLLocationDirection.init(0), animated: true) {
            guard let annotation = mapView.annotations?.first(where: {$0.coordinate.latitude == coords.latitude &&
                                                                      $0.coordinate.longitude == coords.longitude}) else { return }
            mapView.selectAnnotation(annotation, animated: true, completionHandler: nil)
        }
    }
    
    func setTask(coordinateToScale: Coordinates) {
        scaleToCoord = coordinateToScale
        UIApplication.shared.customKeyWindow?.rootViewController?.children.first(where: { $0.children.first(where: {($0 as? MapVC) != nil}) != nil })?.children.first?.navigationController?.popToRootViewController(animated: true)
    }
}
