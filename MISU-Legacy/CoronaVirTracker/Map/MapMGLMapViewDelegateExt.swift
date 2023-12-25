//
//  MapMGLMapViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import Mapbox

extension MapVC: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsUserHeadingIndicator = true
        setUpAnnotations()
        
        // test
        mapView.setCenter(.RivneCoord, zoomLevel: 10, animated: true)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        style.localizeLabels(into: Locale.current)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        //let doctor = doctors(have: annotation)
        guard let hospital = hospitals(have: annotation) else { return }
        
        //shortInfoView = ShortInfoView(parentView: view)
        //shortInfoView?.doctor = doctor
        shortInfoView?.hospital = hospital
        
        if let top = shortInfoView?.topAnchor {
            listButton.customBottomAnchorConstraint?.isActive = false
            listButton.customTopAnchorConstraint = listButton.bottomAnchor.constraint(equalTo: top, constant: -view.standartInset)//.isActive = true
            listButton.animateChangeConstraints(deactivate: listButton.customBottomAnchorConstraint, activate: listButton.customTopAnchorConstraint, duration: 0.3)
        }
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        shortInfoView?.hide()
        listButton.animateChangeConstraints(deactivate: listButton.customTopAnchorConstraint, activate: listButton.customBottomAnchorConstraint, duration: 0.3)
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        //print("didSelect annotationView ...")
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        print(annotation.coordinate)
        let reuseIdentifier = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
            return annotationView
        }
        
        let annotationView = CardMapAnnotationView(reuseIdentifier: reuseIdentifier)
        annotationView.bounds = CGRect(x: 0, y: 0, width: minAnnotHeight, height: minAnnotHeight)
        
        guard let subtitle = annotation.subtitle else { return nil }
        annotationView.type = ListStructEnum.getItem(name: subtitle)
        if subtitle == ListStructEnum.doctors.getItemDescription() {
            annotationView.bounds = CGRect(x: 0, y: 0, width: annotationView.bounds.width*0.7, height: annotationView.bounds.height*0.7)
        }
        
        return annotationView
    }
}
