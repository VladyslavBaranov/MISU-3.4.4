//
//  ListDHUTaskSingletonManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 24.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ListDHUTaskSingletonManager {
    static let shared = ListDHUTaskSingletonManager()
    private init() { }
    
    private var switchToSegment: ListStructEnum?
    private let standartZoomLvL: Double = 16
    
    var isTask: Bool { get { return switchToSegment != nil } }
    
    func doTask(listVC: PatientsVC) {
        //guard let segment = switchToSegment else { return }
        //listVC.segmentController.selectedSegmentIndex = segment.rawValue
        //listVC.segmentedControlValueChanged(segment: listVC.segmentController)
        switchToSegment = nil
    }
    
    func setTask(segment: ListStructEnum) {
        switchToSegment = segment
        
        UIApplication.shared.customKeyWindow?.rootViewController?.children.first(where: { $0.children.first(where: {($0 as? PatientsVC) != nil}) != nil })?.children.first?.navigationController?.popToRootViewController(animated: true)
    }
}
