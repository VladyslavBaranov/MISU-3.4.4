//
//  WatchManagerDef.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.12.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

class WatchManager {
    var isConnected: Bool {
        return false
    }
    
    var sleepHistory: HistoricalSleep = [:]
    
    
    /// Flag for updating status of device
    /// - is device currently updating or not
    var isUpdating: Bool = false
    
    /// Count of current updating Processes
    /// - if chenges to 0 than automatically switches isUpdating to false
    /// - if chenges to more than 0 than automatically switches isUpdating to true
    /// - if chenges to less than 0 than chenges itself to 0
    /// - To USAGE use addUpdateProcess or removeUpdateProcess methods
    var updatingProcessesCount: Int = 0 {
        didSet {
            if updatingProcessesCount == 0 { isUpdating = false }
            if updatingProcessesCount > 0 { isUpdating = true }
            if updatingProcessesCount < 0 { updatingProcessesCount = 0 }
        }
    }
    
    /// Adds ONE procces to updatingProcessesCount
    /// - Method to use Process status tools
    func addUpdatingProcess() {
        updatingProcessesCount += 1
    }
    
    /// Removes ONE procces to updatingProcessesCount
    /// - Method to use Process status tools
    func removeUpdatingProcess() {
        updatingProcessesCount -= 1
    }
}

// Feature: Add unic methots for retrieving all types of data from gadgets
extension WatchManager {
    @objc func updateAllData() {}
}
