//
//  MapVC.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/12/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import MapKit
import Mapbox

// MARK: - Components
class MapVC: UIViewController {
    var mapView: MGLMapView = .init()
    let locationManager = CLLocationManager()
    let listButton: UIButton = .createCustom(withImage: UIImage(named: "AsListImage"), backgroundColor: .white, imageRenderingMode: .alwaysOriginal, shadow: true)
    
    var annotations: [MGLAnnotation] = []
    var doctors: [UserModel] = []
    var hospitals: [HospitalModel] = []
    
    let minAnnotHeight: CGFloat = 50
    
    var isCitySelector = false
    var isShortInfoView = false
    
    var shortInfoView: ShortInfoView? = nil
}



// MARK: - View loads Overrides
extension MapVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setUpMap()
        setUpSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MapTaskSingletonManager.shared.doTask(mapView)
        setUpData()
    }
}



// MARK: - Annotations methods
extension MapVC {
    func doctors(have annotation: MGLAnnotation) -> UserModel? {
        return doctors.first(where: {
            String($0.id) == annotation.title && annotation.subtitle == ListStructEnum.doctors.getItemDescription()})
    }
    
    func hospitals(have annotation: MGLAnnotation) -> HospitalModel? {
        return hospitals.first(where: { hosp -> Bool in
            let title = String(hosp.id) + (hosp.location?.getFullLocationStr() ?? "")
            return title == annotation.title && annotation.subtitle == ListStructEnum.hospitals.getItemDescription()
        })//t(where: {
            //String($0.id) == annotation.title && annotation.subtitle == ListStructEnum.hospitals.getItemDescription()})
    }
    
    func annotations(have id: Int, locationName: String? = nil, type: ListStructEnum) -> Bool {
        if type == .hospitals {
            if (annotations.first(where: { annot -> Bool in
                let title = String(id) + (locationName ?? "")
                return title == annot.title && annot.subtitle == type.getItemDescription()
            }) != nil){
                return true
            }
        }
        if annotations.first(where: {$0.title == String(id) &&
            $0.subtitle == type.getItemDescription()}) != nil {
            return true
        }
        return false
    }
    
    func addToAnnotations(_ doctor: UserModel) {
        guard let coord = doctor.location?.coordinate?.getCLLC2D() else {return}
        
        let annot = MGLPointAnnotation()
        annot.coordinate = coord
        annot.title = String(doctor.id)
        annot.subtitle = ListStructEnum.doctors.getItemDescription()
        
        annotations.append(annot)
        mapView.addAnnotation(annot)
    }
    
    func addToAnnotations(_ hospital: HospitalModel) {
        guard let coord = hospital.location?.coordinate?.getCLLC2D() else {return}
        
        let annot = MGLPointAnnotation()
        annot.coordinate = coord
        annot.title = String(hospital.id) + (hospital.location?.getFullLocationStr() ?? "")
        annot.subtitle = ListStructEnum.hospitals.getItemDescription()
        
        annotations.append(annot)
        mapView.addAnnotation(annot)
    }
}
    


// MARK: - Other methods
extension MapVC {
    func isUserLocation() {

        if UCardSingleManager.shared.user.location == nil {
            if isCitySelector { return }
            isCitySelector = true
            
            let citySelector = CitySelectorModalView(frame: view.frame)
            citySelector.show { location in
                let old = UCardSingleManager.shared.user
                UCardSingleManager.shared.user.location = location
                UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true)
                UCardSingleManager.shared.createLocation(location: location)
                if let coord = location.coordinate {
                    self.mapView.setCenter(CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude), zoomLevel: 9, animated: false)
                }
                self.isCitySelector = false
            }
        }
    }
    
    @objc func ListButtonAction() {
        let vc = ListDHUVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - SetUp Methods
extension MapVC {
    func setUpSubViews() {
        mapView.addSubview(listButton)
        
        listButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -mapView.standartInset).isActive = true
        listButton.customBottomAnchorConstraint = listButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -mapView.standartInset)
        listButton.customBottomAnchorConstraint?.isActive = true
        listButton.widthAnchor.constraint(equalToConstant: view.standartInset*3).isActive = true
        listButton.heightAnchor.constraint(equalToConstant: view.standartInset*3).isActive = true
        listButton.addTarget(self, action: #selector(ListButtonAction), for: .touchUpInside)
        shortInfoView = ShortInfoView(parentView: view)
    }
    
    func setUpData() {
        //doctors = ListDHUSingleManager.shared.doctors
        hospitals = ListDHUSingleManager.shared.hospitals
        
        ListDHUSingleManager.shared.updateData {
            DispatchQueue.main.async {
                //self.doctors = ListDHUSingleManager.shared.doctors
                self.hospitals = ListDHUSingleManager.shared.hospitals
                self.setUpAnnotations()
            }
        }
    }
    
    func setUpMap() {
        mapView = MGLMapView(frame: view.frame)
        view = mapView
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/streets-v11")
        mapView.delegate = self
        mapView.frame = view.bounds
        mapView.attributionButton.alpha = 0.0
        mapView.logoView.alpha = 0.0
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = UIColor.lightGray
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled")
            isUserLocation()
        }
    }
    
    func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setUpAnnotations() {
        var annotToRemove: [MGLAnnotation] = []
        
        for annot in annotations {
            var isAnnot = false
            
            if doctors(have: annot) != nil {
                isAnnot = true
            }
            
            if hospitals(have: annot) != nil {
                isAnnot = true
            }
            
            if !isAnnot {
                annotToRemove.append(annot)
                annotations.removeAll(where: {$0.title == annot.title})
            }
        }
        
        mapView.removeAnnotations(annotToRemove)
        
        for doctor in doctors {
            if !annotations(have: doctor.id, type: .doctors) {
                addToAnnotations(doctor)
            }
        }
        
        for hospital in hospitals {
            if !annotations(have: hospital.id, locationName: hospital.location?.getFullLocationStr(), type: .hospitals) {
                addToAnnotations(hospital)
            }
        }
    }
}
